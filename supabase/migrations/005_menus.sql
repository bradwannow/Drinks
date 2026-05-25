-- Pour app — menu capture, versioning, and OCR pipeline
-- Run after 004_activity.sql

-- ---------------------------------------------------------------------------
-- Storage bucket for menu photos
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'menu-images',
  'menu-images',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/heic', 'image/webp']
)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- menus — one logical menu container per bar
-- ---------------------------------------------------------------------------

create table if not exists public.menus (
  id uuid primary key default gen_random_uuid(),
  bar_id uuid not null unique references public.bars (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists menus_bar_id_idx on public.menus (bar_id);

-- ---------------------------------------------------------------------------
-- menu_versions — each upload is a historical snapshot
-- ---------------------------------------------------------------------------

create table if not exists public.menu_versions (
  id uuid primary key default gen_random_uuid(),
  menu_id uuid not null references public.menus (id) on delete cascade,
  bar_id uuid not null references public.bars (id) on delete cascade,
  contributor_id uuid references public.profiles (id) on delete set null,
  season_label text,
  season_month smallint check (season_month is null or season_month between 1 and 12),
  is_current boolean not null default false,
  notes text,
  ocr_status text not null default 'pending' check (
    ocr_status in ('pending', 'processing', 'completed', 'failed', 'skipped')
  ),
  uploaded_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists menu_versions_bar_id_idx on public.menu_versions (bar_id);
create index if not exists menu_versions_menu_id_idx on public.menu_versions (menu_id);
create index if not exists menu_versions_uploaded_at_idx on public.menu_versions (uploaded_at desc);
create index if not exists menu_versions_current_idx on public.menu_versions (bar_id, is_current) where is_current = true;

-- ---------------------------------------------------------------------------
-- menu_images — multiple photos per version
-- ---------------------------------------------------------------------------

create table if not exists public.menu_images (
  id uuid primary key default gen_random_uuid(),
  menu_version_id uuid not null references public.menu_versions (id) on delete cascade,
  storage_path text not null,
  sort_order int not null default 0,
  ocr_raw_text text,
  created_at timestamptz not null default now()
);

create index if not exists menu_images_version_idx on public.menu_images (menu_version_id, sort_order);

-- ---------------------------------------------------------------------------
-- menu_cocktails — OCR-extracted entries with manual correction support
-- ---------------------------------------------------------------------------

create table if not exists public.menu_cocktails (
  id uuid primary key default gen_random_uuid(),
  menu_version_id uuid not null references public.menu_versions (id) on delete cascade,
  name text not null,
  description text not null default '',
  price_text text,
  sort_order int not null default 0,
  ocr_confidence real,
  is_manually_edited boolean not null default false,
  cocktail_id uuid references public.cocktails (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists menu_cocktails_version_idx on public.menu_cocktails (menu_version_id, sort_order);

-- ---------------------------------------------------------------------------
-- Ensure only one current menu per bar
-- ---------------------------------------------------------------------------

create or replace function public.enforce_single_current_menu()
returns trigger
language plpgsql
as $$
begin
  if new.is_current then
    update public.menu_versions
    set is_current = false, updated_at = now()
    where bar_id = new.bar_id
      and id <> new.id
      and is_current = true;
  end if;
  return new;
end;
$$;

create trigger menu_versions_enforce_single_current
  before insert or update of is_current on public.menu_versions
  for each row
  when (new.is_current)
  execute function public.enforce_single_current_menu();

create trigger menu_versions_set_updated_at
  before update on public.menu_versions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Auto-create menu container for a bar on first upload
-- ---------------------------------------------------------------------------

create or replace function public.ensure_menu_for_bar(p_bar_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_menu_id uuid;
begin
  select id into v_menu_id from public.menus where bar_id = p_bar_id;

  if v_menu_id is null then
    insert into public.menus (bar_id) values (p_bar_id) returning id into v_menu_id;
  end if;

  return v_menu_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.menus enable row level security;
alter table public.menu_versions enable row level security;
alter table public.menu_images enable row level security;
alter table public.menu_cocktails enable row level security;

create policy "Public read menus"
  on public.menus for select
  using (true);

create policy "Authenticated insert menus"
  on public.menus for insert
  with check (auth.uid() is not null);

create policy "Public read menu_versions"
  on public.menu_versions for select
  using (true);

create policy "Authenticated insert menu_versions"
  on public.menu_versions for insert
  with check (auth.uid() = contributor_id);

create policy "Contributors update own menu_versions"
  on public.menu_versions for update
  using (auth.uid() = contributor_id);

create policy "Public read menu_images"
  on public.menu_images for select
  using (true);

create policy "Authenticated insert menu_images"
  on public.menu_images for insert
  with check (
    exists (
      select 1 from public.menu_versions mv
      where mv.id = menu_version_id
        and mv.contributor_id = auth.uid()
    )
  );

create policy "Contributors update own menu_images"
  on public.menu_images for update
  using (
    exists (
      select 1 from public.menu_versions mv
      where mv.id = menu_version_id
        and mv.contributor_id = auth.uid()
    )
  );

create policy "Public read menu_cocktails"
  on public.menu_cocktails for select
  using (true);

create policy "Authenticated insert menu_cocktails"
  on public.menu_cocktails for insert
  with check (
    exists (
      select 1 from public.menu_versions mv
      where mv.id = menu_version_id
        and mv.contributor_id = auth.uid()
    )
  );

create policy "Contributors update own menu_cocktails"
  on public.menu_cocktails for update
  using (
    exists (
      select 1 from public.menu_versions mv
      where mv.id = menu_version_id
        and mv.contributor_id = auth.uid()
    )
  );

create policy "Contributors delete own menu_cocktails"
  on public.menu_cocktails for delete
  using (
    exists (
      select 1 from public.menu_versions mv
      where mv.id = menu_version_id
        and mv.contributor_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Storage policies
-- ---------------------------------------------------------------------------

create policy "Public read menu images"
  on storage.objects for select
  using (bucket_id = 'menu-images');

create policy "Authenticated upload menu images"
  on storage.objects for insert
  with check (
    bucket_id = 'menu-images'
    and auth.uid() is not null
  );

create policy "Contributors update own menu images"
  on storage.objects for update
  using (
    bucket_id = 'menu-images'
    and auth.uid() is not null
  );

create policy "Contributors delete own menu images"
  on storage.objects for delete
  using (
    bucket_id = 'menu-images'
    and auth.uid() is not null
  );
