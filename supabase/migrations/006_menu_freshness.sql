-- Pour app — menu freshness, community validation, and trust signals
-- Run after 005_menus.sql

-- ---------------------------------------------------------------------------
-- Trust & freshness columns on menu_versions
-- ---------------------------------------------------------------------------

alter table public.menu_versions
  add column if not exists confirmation_count int not null default 0,
  add column if not exists confidence_score real not null default 0,
  add column if not exists is_outdated boolean not null default false,
  add column if not exists outdated_report_count int not null default 0;

create index if not exists menu_versions_freshness_idx
  on public.menu_versions (uploaded_at desc)
  where is_current = true and is_outdated = false;

create index if not exists menu_versions_seasonal_idx
  on public.menu_versions (uploaded_at desc)
  where is_current = true and season_label is not null;

-- ---------------------------------------------------------------------------
-- Community confirmations — one per user per menu version
-- ---------------------------------------------------------------------------

create table if not exists public.menu_confirmations (
  id uuid primary key default gen_random_uuid(),
  menu_version_id uuid not null references public.menu_versions (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (menu_version_id, user_id)
);

create index if not exists menu_confirmations_version_idx
  on public.menu_confirmations (menu_version_id);

-- ---------------------------------------------------------------------------
-- Outdated reports — lightweight flagging, one per user per version
-- ---------------------------------------------------------------------------

create table if not exists public.menu_outdated_reports (
  id uuid primary key default gen_random_uuid(),
  menu_version_id uuid not null references public.menu_versions (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (menu_version_id, user_id)
);

create index if not exists menu_outdated_reports_version_idx
  on public.menu_outdated_reports (menu_version_id);

-- ---------------------------------------------------------------------------
-- Recompute confidence from confirmations + recency
-- ---------------------------------------------------------------------------

create or replace function public.recompute_menu_confidence(p_menu_version_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_uploaded timestamptz;
  v_recency real;
  v_score real;
begin
  select confirmation_count, uploaded_at
  into v_count, v_uploaded
  from public.menu_versions
  where id = p_menu_version_id;

  v_recency := case
    when v_uploaded > now() - interval '24 hours' then 0.35
    when v_uploaded > now() - interval '7 days' then 0.25
    when v_uploaded > now() - interval '30 days' then 0.15
    else 0.05
  end;

  v_score := least(1.0, v_count * 0.12 + v_recency);

  update public.menu_versions
  set confidence_score = v_score,
      updated_at = now()
  where id = p_menu_version_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Confirm current menu (community validation)
-- ---------------------------------------------------------------------------

create or replace function public.confirm_menu(p_menu_version_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_contributor uuid;
  v_is_current boolean;
begin
  if v_user_id is null then
    raise exception 'Unauthorized';
  end if;

  select contributor_id, is_current
  into v_contributor, v_is_current
  from public.menu_versions
  where id = p_menu_version_id;

  if not found then
    raise exception 'Menu not found';
  end if;

  if not v_is_current then
    raise exception 'Can only confirm current menus';
  end if;

  if v_contributor = v_user_id then
    raise exception 'Cannot confirm your own upload';
  end if;

  insert into public.menu_confirmations (menu_version_id, user_id)
  values (p_menu_version_id, v_user_id)
  on conflict do nothing;

  update public.menu_versions
  set confirmation_count = (
    select count(*)::int
    from public.menu_confirmations
    where menu_version_id = p_menu_version_id
  ),
  is_outdated = false
  where id = p_menu_version_id;

  perform public.recompute_menu_confidence(p_menu_version_id);

  return (
    select json_build_object(
      'confirmation_count', confirmation_count,
      'confidence_score', confidence_score,
      'is_outdated', is_outdated
    )
    from public.menu_versions
    where id = p_menu_version_id
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Report menu as outdated
-- ---------------------------------------------------------------------------

create or replace function public.report_menu_outdated(p_menu_version_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_is_current boolean;
  v_reports int;
  v_confidence real;
begin
  if v_user_id is null then
    raise exception 'Unauthorized';
  end if;

  select is_current
  into v_is_current
  from public.menu_versions
  where id = p_menu_version_id;

  if not found then
    raise exception 'Menu not found';
  end if;

  if not v_is_current then
    raise exception 'Can only report current menus';
  end if;

  insert into public.menu_outdated_reports (menu_version_id, user_id)
  values (p_menu_version_id, v_user_id)
  on conflict do nothing;

  update public.menu_versions
  set outdated_report_count = (
    select count(*)::int
    from public.menu_outdated_reports
    where menu_version_id = p_menu_version_id
  )
  where id = p_menu_version_id;

  select outdated_report_count, confidence_score
  into v_reports, v_confidence
  from public.menu_versions
  where id = p_menu_version_id;

  update public.menu_versions
  set is_outdated = (v_reports >= 2 or (v_reports >= 1 and v_confidence < 0.3))
  where id = p_menu_version_id;

  return (
    select json_build_object(
      'outdated_report_count', outdated_report_count,
      'is_outdated', is_outdated
    )
    from public.menu_versions
    where id = p_menu_version_id
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Viewer state for authenticated users
-- ---------------------------------------------------------------------------

create or replace function public.menu_viewer_state(p_menu_version_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    return json_build_object('has_confirmed', false, 'has_reported_outdated', false);
  end if;

  return json_build_object(
    'has_confirmed', exists (
      select 1 from public.menu_confirmations
      where menu_version_id = p_menu_version_id and user_id = v_user_id
    ),
    'has_reported_outdated', exists (
      select 1 from public.menu_outdated_reports
      where menu_version_id = p_menu_version_id and user_id = v_user_id
    )
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.menu_confirmations enable row level security;
alter table public.menu_outdated_reports enable row level security;

create policy "Public read menu_confirmations"
  on public.menu_confirmations for select
  using (true);

create policy "Public read menu_outdated_reports"
  on public.menu_outdated_reports for select
  using (true);

-- Inserts go through security definer RPCs only

grant execute on function public.confirm_menu(uuid) to authenticated;
grant execute on function public.report_menu_outdated(uuid) to authenticated;
grant execute on function public.menu_viewer_state(uuid) to authenticated, anon;
