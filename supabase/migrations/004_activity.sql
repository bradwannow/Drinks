-- Pour app — activity, freshness, and notification preferences
-- Run after 003_profiles_username.sql

-- ---------------------------------------------------------------------------
-- Cocktail & bar freshness columns
-- ---------------------------------------------------------------------------

alter table public.cocktails
  add column if not exists is_limited_time boolean not null default false,
  add column if not exists is_staff_pick boolean not null default false,
  add column if not exists available_until timestamptz;

alter table public.bars
  add column if not exists is_newly_opened boolean not null default false;

create index if not exists cocktails_created_at_idx on public.cocktails (created_at desc);
create index if not exists bars_created_at_idx on public.bars (created_at desc);

-- ---------------------------------------------------------------------------
-- Activity feed
-- ---------------------------------------------------------------------------

create table if not exists public.activity_feed (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in (
    'new_cocktail',
    'seasonal_drop',
    'featured_cocktail',
    'trending_bar',
    'happy_hour_soon',
    'new_bar'
  )),
  title text not null,
  subtitle text,
  bar_id uuid references public.bars (id) on delete cascade,
  cocktail_id uuid references public.cocktails (id) on delete cascade,
  image_url text,
  starts_at timestamptz,
  ends_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists activity_feed_created_at_idx on public.activity_feed (created_at desc);
create index if not exists activity_feed_active_idx on public.activity_feed (is_active) where is_active = true;

-- ---------------------------------------------------------------------------
-- Bar updates
-- ---------------------------------------------------------------------------

create table if not exists public.bar_updates (
  id uuid primary key default gen_random_uuid(),
  bar_id uuid not null references public.bars (id) on delete cascade,
  type text not null check (type in (
    'menu_update',
    'limited_cocktail',
    'seasonal_special',
    'event_night'
  )),
  title text not null,
  description text not null,
  cocktail_id uuid references public.cocktails (id) on delete set null,
  event_date date,
  starts_at timestamptz,
  ends_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists bar_updates_bar_id_idx on public.bar_updates (bar_id);
create index if not exists bar_updates_created_at_idx on public.bar_updates (created_at desc);

-- ---------------------------------------------------------------------------
-- Notification preferences (future push infrastructure)
-- ---------------------------------------------------------------------------

create table if not exists public.notification_preferences (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  saved_bar_cocktails boolean not null default true,
  happy_hour_reminders boolean not null default true,
  seasonal_launches boolean not null default true,
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.activity_feed enable row level security;
alter table public.bar_updates enable row level security;
alter table public.notification_preferences enable row level security;

create policy "Public read activity_feed"
  on public.activity_feed for select
  using (is_active = true);

create policy "Public read bar_updates"
  on public.bar_updates for select
  using (is_active = true);

create policy "Users read own notification preferences"
  on public.notification_preferences for select
  using (auth.uid() = user_id);

create policy "Users insert own notification preferences"
  on public.notification_preferences for insert
  with check (auth.uid() = user_id);

create policy "Users update own notification preferences"
  on public.notification_preferences for update
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Seed freshness flags on existing Chicago data
-- ---------------------------------------------------------------------------

update public.cocktails set
  is_limited_time = true,
  is_staff_pick = false,
  available_until = now() + interval '14 days'
where id = 'b2000001-0000-4000-8000-000000000003';

update public.cocktails set
  is_staff_pick = true,
  is_limited_time = false
where id in (
  'b2000001-0000-4000-8000-000000000001',
  'b2000001-0000-4000-8000-000000000008'
);

update public.cocktails set
  is_limited_time = true,
  available_until = (current_date + interval '1 day')::timestamptz + interval '2 hours'
where id = 'b2000001-0000-4000-8000-000000000008';

update public.bars set is_newly_opened = true
where id = 'a2000001-0000-4000-8000-000000000004';

-- ---------------------------------------------------------------------------
-- Seed activity feed
-- ---------------------------------------------------------------------------

delete from public.activity_feed
where id in (
  'd4000001-0000-4000-8000-000000000001',
  'd4000001-0000-4000-8000-000000000002',
  'd4000001-0000-4000-8000-000000000003',
  'd4000001-0000-4000-8000-000000000004',
  'd4000001-0000-4000-8000-000000000005',
  'd4000001-0000-4000-8000-000000000006',
  'd4000001-0000-4000-8000-000000000007',
  'd4000001-0000-4000-8000-000000000008'
);

insert into public.activity_feed (id, type, title, subtitle, bar_id, cocktail_id, image_url, starts_at, ends_at) values
  (
    'd4000001-0000-4000-8000-000000000001',
    'new_cocktail',
    'Penicillin lands at Lazy Bird',
    'Smoky scotch with an Islay float — just added',
    'a2000001-0000-4000-8000-000000000004',
    'b2000001-0000-4000-8000-000000000010',
    'https://images.unsplash.com/photo-1551024709-8f23be4d0087?w=800&q=80',
    now() - interval '2 days',
    null
  ),
  (
    'd4000001-0000-4000-8000-000000000002',
    'seasonal_drop',
    'Root Beer Old Fashioned returns',
    'Smoked cedar, bourbon, and root beer reduction',
    'a2000001-0000-4000-8000-000000000003',
    'b2000001-0000-4000-8000-000000000003',
    'https://images.unsplash.com/photo-1527281400683-1aae59a916a5?w=800&q=80',
    now() - interval '1 day',
    now() + interval '30 days'
  ),
  (
    'd4000001-0000-4000-8000-000000000003',
    'featured_cocktail',
    'Tonight''s featured pour',
    'Violet Hour Negroni — barrel-aged perfection',
    'a2000001-0000-4000-8000-000000000001',
    'b2000001-0000-4000-8000-000000000001',
    'https://images.unsplash.com/photo-1514362545857-3bc165c4d737?w=800&q=80',
    now(),
    null
  ),
  (
    'd4000001-0000-4000-8000-000000000004',
    'trending_bar',
    'Scofflaw is trending tonight',
    'Logan Square fireplace vibes and serious Negronis',
    'a2000001-0000-4000-8000-000000000002',
    null,
    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80',
    now(),
    null
  ),
  (
    'd4000001-0000-4000-8000-000000000005',
    'happy_hour_soon',
    'Happy hour starts at Scofflaw',
    '5 – 7 PM · $10 gin classics and half-off cheese boards',
    'a2000001-0000-4000-8000-000000000002',
    null,
    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80',
    now() + interval '30 minutes',
    now() + interval '2 hours 30 minutes'
  ),
  (
    'd4000001-0000-4000-8000-000000000006',
    'new_bar',
    'Lazy Bird just opened',
    'Basement speakeasy beneath The Aviary',
    'a2000001-0000-4000-8000-000000000004',
    null,
    'https://images.unsplash.com/photo-1571249477469-303375066f11?w=600&q=80',
    now() - interval '5 days',
    null
  ),
  (
    'd4000001-0000-4000-8000-000000000007',
    'seasonal_drop',
    'Three Dots and a Dash — tiki season',
    'Chicago''s finest tiki punch returns to Lost Lake',
    'a2000001-0000-4000-8000-000000000005',
    'b2000001-0000-4000-8000-000000000008',
    'https://images.unsplash.com/photo-1546171753-97d0dbd11023?w=800&q=80',
    now(),
    now() + interval '45 days'
  ),
  (
    'd4000001-0000-4000-8000-000000000008',
    'new_cocktail',
    'Bee''s Knees at Scofflaw',
    'Bright gin, lemon, and local honey — new on the menu',
    'a2000001-0000-4000-8000-000000000002',
    'b2000001-0000-4000-8000-000000000006',
    'https://images.unsplash.com/photo-1551538826-4c7acaaef387?w=800&q=80',
    now() - interval '3 days',
    null
  );

-- ---------------------------------------------------------------------------
-- Seed bar updates
-- ---------------------------------------------------------------------------

delete from public.bar_updates
where id in (
  'e4000001-0000-4000-8000-000000000001',
  'e4000001-0000-4000-8000-000000000002',
  'e4000001-0000-4000-8000-000000000003',
  'e4000001-0000-4000-8000-000000000004',
  'e4000001-0000-4000-8000-000000000005',
  'e4000001-0000-4000-8000-000000000006'
);

insert into public.bar_updates (id, bar_id, type, title, description, cocktail_id, event_date, starts_at, ends_at) values
  (
    'e4000001-0000-4000-8000-000000000001',
    'a2000001-0000-4000-8000-000000000001',
    'seasonal_special',
    'Spring Aperitif Menu',
    'Light, floral highballs and spritzes rotating through April.',
    null,
    null,
    now(),
    now() + interval '30 days'
  ),
  (
    'e4000001-0000-4000-8000-000000000002',
    'a2000001-0000-4000-8000-000000000002',
    'limited_cocktail',
    'Barrel-Aged Negroni — 20 bottles left',
    'House barrel rest for 6 weeks. When it''s gone, it''s gone.',
    'b2000001-0000-4000-8000-000000000001',
    null,
    now(),
    now() + interval '10 days'
  ),
  (
    'e4000001-0000-4000-8000-000000000003',
    'a2000001-0000-4000-8000-000000000003',
    'menu_update',
    'New smoke program cocktails',
    'Aviary team rolled out three new smoked presentations this week.',
    'b2000001-0000-4000-8000-000000000003',
    null,
    now() - interval '1 day',
    null
  ),
  (
    'e4000001-0000-4000-8000-000000000004',
    'a2000001-0000-4000-8000-000000000004',
    'event_night',
    'Jazz & Martinis — Thursday',
    'Live trio, classic martini flight, no cover before 8 PM.',
    null,
    current_date + ((4 - extract(dow from current_date)::int + 7) % 7),
    null,
    null
  ),
  (
    'e4000001-0000-4000-8000-000000000005',
    'a2000001-0000-4000-8000-000000000005',
    'seasonal_special',
    'Tiki Week at Lost Lake',
    'Extended rum list and orchid garnishes all week long.',
    'b2000001-0000-4000-8000-000000000008',
    null,
    now(),
    now() + interval '7 days'
  ),
  (
    'e4000001-0000-4000-8000-000000000006',
    'a2000001-0000-4000-8000-000000000002',
    'menu_update',
    'Two new gin classics',
    'Bee''s Knees and a clarified Milk Punch join the permanent menu.',
    'b2000001-0000-4000-8000-000000000006',
    null,
    now() - interval '3 days',
    null
  );
