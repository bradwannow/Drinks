-- Pour app — initial schema
-- Run in Supabase SQL Editor or via supabase db push

-- ---------------------------------------------------------------------------
-- Profiles (extends auth.users)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Bars
-- ---------------------------------------------------------------------------

create table public.bars (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  neighborhood text not null,
  tagline text not null,
  rating numeric(2, 1) not null default 0 check (rating >= 0 and rating <= 5),
  image_url text not null,
  latitude double precision not null,
  longitude double precision not null,
  is_trending boolean not null default false,
  is_featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index bars_is_trending_idx on public.bars (is_trending) where is_trending = true;
create index bars_is_featured_idx on public.bars (is_featured) where is_featured = true;

-- ---------------------------------------------------------------------------
-- Cocktails
-- ---------------------------------------------------------------------------

create table public.cocktails (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null,
  image_url text not null,
  spirit text not null,
  is_seasonal boolean not null default false,
  is_featured boolean not null default false,
  is_trending boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index cocktails_is_featured_idx on public.cocktails (is_featured) where is_featured = true;
create index cocktails_is_trending_idx on public.cocktails (is_trending) where is_trending = true;

-- ---------------------------------------------------------------------------
-- Bar ↔ Cocktail (many-to-many)
-- ---------------------------------------------------------------------------

create table public.bar_cocktails (
  id uuid primary key default gen_random_uuid(),
  bar_id uuid not null references public.bars (id) on delete cascade,
  cocktail_id uuid not null references public.cocktails (id) on delete cascade,
  is_signature boolean not null default false,
  created_at timestamptz not null default now(),
  unique (bar_id, cocktail_id)
);

create index bar_cocktails_bar_id_idx on public.bar_cocktails (bar_id);
create index bar_cocktails_cocktail_id_idx on public.bar_cocktails (cocktail_id);

-- ---------------------------------------------------------------------------
-- Happy hours (belong to a bar)
-- ---------------------------------------------------------------------------

create table public.happy_hours (
  id uuid primary key default gen_random_uuid(),
  bar_id uuid not null references public.bars (id) on delete cascade,
  time_range text not null,
  deal_description text not null,
  days_active text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index happy_hours_bar_id_idx on public.happy_hours (bar_id);

-- ---------------------------------------------------------------------------
-- User saves
-- ---------------------------------------------------------------------------

create table public.saved_bars (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  bar_id uuid not null references public.bars (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, bar_id)
);

create index saved_bars_user_id_idx on public.saved_bars (user_id);

create table public.saved_cocktails (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  cocktail_id uuid not null references public.cocktails (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, cocktail_id)
);

create index saved_cocktails_user_id_idx on public.saved_cocktails (user_id);

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger bars_set_updated_at
  before update on public.bars
  for each row execute function public.set_updated_at();

create trigger cocktails_set_updated_at
  before update on public.cocktails
  for each row execute function public.set_updated_at();

create trigger happy_hours_set_updated_at
  before update on public.happy_hours
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Auto-create profile on signup
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.bars enable row level security;
alter table public.cocktails enable row level security;
alter table public.bar_cocktails enable row level security;
alter table public.happy_hours enable row level security;
alter table public.saved_bars enable row level security;
alter table public.saved_cocktails enable row level security;

-- Public read for discovery content
create policy "Public read bars"
  on public.bars for select
  using (true);

create policy "Public read cocktails"
  on public.cocktails for select
  using (true);

create policy "Public read bar_cocktails"
  on public.bar_cocktails for select
  using (true);

create policy "Public read happy_hours"
  on public.happy_hours for select
  using (true);

-- Profiles: users manage their own row
create policy "Users read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Saved bars
create policy "Users read own saved bars"
  on public.saved_bars for select
  using (auth.uid() = user_id);

create policy "Users insert own saved bars"
  on public.saved_bars for insert
  with check (auth.uid() = user_id);

create policy "Users delete own saved bars"
  on public.saved_bars for delete
  using (auth.uid() = user_id);

-- Saved cocktails
create policy "Users read own saved cocktails"
  on public.saved_cocktails for select
  using (auth.uid() = user_id);

create policy "Users insert own saved cocktails"
  on public.saved_cocktails for insert
  with check (auth.uid() = user_id);

create policy "Users delete own saved cocktails"
  on public.saved_cocktails for delete
  using (auth.uid() = user_id);
