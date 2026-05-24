-- Pour app — Chicago cocktail bar seed data
-- Run after 001_schema.sql
-- Schema-compatible INSERTs only (no DDL)

-- ---------------------------------------------------------------------------
-- Optional: clear prior seed rows before re-running (safe for dev)
-- ---------------------------------------------------------------------------

delete from public.happy_hours
where id in (
  'c3000001-0000-4000-8000-000000000001',
  'c3000001-0000-4000-8000-000000000002',
  'c3000001-0000-4000-8000-000000000003',
  'c3000001-0000-4000-8000-000000000004',
  'c3000001-0000-4000-8000-000000000005'
);

delete from public.bar_cocktails
where bar_id in (
  'a2000001-0000-4000-8000-000000000001',
  'a2000001-0000-4000-8000-000000000002',
  'a2000001-0000-4000-8000-000000000003',
  'a2000001-0000-4000-8000-000000000004',
  'a2000001-0000-4000-8000-000000000005'
);

delete from public.cocktails
where id in (
  'b2000001-0000-4000-8000-000000000001',
  'b2000001-0000-4000-8000-000000000002',
  'b2000001-0000-4000-8000-000000000003',
  'b2000001-0000-4000-8000-000000000004',
  'b2000001-0000-4000-8000-000000000005',
  'b2000001-0000-4000-8000-000000000006',
  'b2000001-0000-4000-8000-000000000007',
  'b2000001-0000-4000-8000-000000000008',
  'b2000001-0000-4000-8000-000000000009',
  'b2000001-0000-4000-8000-000000000010'
);

delete from public.bars
where id in (
  'a2000001-0000-4000-8000-000000000001',
  'a2000001-0000-4000-8000-000000000002',
  'a2000001-0000-4000-8000-000000000003',
  'a2000001-0000-4000-8000-000000000004',
  'a2000001-0000-4000-8000-000000000005'
);

-- Also remove legacy NYC seed rows if present
delete from public.happy_hours
where bar_id in (
  'a1000001-0000-4000-8000-000000000001',
  'a1000001-0000-4000-8000-000000000002',
  'a1000001-0000-4000-8000-000000000003',
  'a1000001-0000-4000-8000-000000000004',
  'a1000001-0000-4000-8000-000000000005'
);

delete from public.bar_cocktails
where bar_id in (
  'a1000001-0000-4000-8000-000000000001',
  'a1000001-0000-4000-8000-000000000002',
  'a1000001-0000-4000-8000-000000000003',
  'a1000001-0000-4000-8000-000000000004',
  'a1000001-0000-4000-8000-000000000005'
);

delete from public.bars
where id in (
  'a1000001-0000-4000-8000-000000000001',
  'a1000001-0000-4000-8000-000000000002',
  'a1000001-0000-4000-8000-000000000003',
  'a1000001-0000-4000-8000-000000000004',
  'a1000001-0000-4000-8000-000000000005'
);

-- ---------------------------------------------------------------------------
-- Bars (5) — real Chicago cocktail destinations
-- ---------------------------------------------------------------------------

insert into public.bars (id, name, neighborhood, tagline, rating, image_url, latitude, longitude, is_trending, is_featured) values
  (
    'a2000001-0000-4000-8000-000000000001',
    'The Violet Hour',
    'Wicker Park',
    'Unmarked door, velvet booths, classic cocktails done flawlessly',
    4.8,
    'https://images.unsplash.com/photo-1572116469694-31de07792adf?w=600&q=80',
    41.9072,
    -87.6770,
    true,
    true
  ),
  (
    'a2000001-0000-4000-8000-000000000002',
    'Scofflaw',
    'Logan Square',
    'Prohibition-era gin bar with a fireplace and serious Negronis',
    4.7,
    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80',
    41.9230,
    -87.6972,
    true,
    true
  ),
  (
    'a2000001-0000-4000-8000-000000000003',
    'The Aviary',
    'West Loop',
    'Avant-garde cocktails from the team behind Alinea',
    4.9,
    'https://images.unsplash.com/photo-1566417713940-b755a4550a42?w=600&q=80',
    41.8865,
    -87.6517,
    true,
    false
  ),
  (
    'a2000001-0000-4000-8000-000000000004',
    'Lazy Bird',
    'West Loop',
    'Basement speakeasy beneath The Aviary — timeless, unhurried pours',
    4.6,
    'https://images.unsplash.com/photo-1571249477469-303375066f11?w=600&q=80',
    41.8863,
    -87.6515,
    true,
    false
  ),
  (
    'a2000001-0000-4000-8000-000000000005',
    'Lost Lake',
    'Logan Square',
    'Tiki escape on Milwaukee Ave — rum, orchids, and late-night energy',
    4.7,
    'https://images.unsplash.com/photo-1514362545857-3bc165c4d737?w=600&q=80',
    41.9234,
    -87.6975,
    false,
    true
  );

-- ---------------------------------------------------------------------------
-- Cocktails (10)
-- ---------------------------------------------------------------------------

insert into public.cocktails (id, name, description, image_url, spirit, is_seasonal, is_featured, is_trending) values
  (
    'b2000001-0000-4000-8000-000000000001',
    'Violet Hour Negroni',
    'Barrel-aged gin, Campari, and sweet vermouth stirred long over a hand-cut ice sphere.',
    'https://images.unsplash.com/photo-1514362545857-3bc165c4d737?w=800&q=80',
    'Gin',
    false,
    true,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000002',
    'Scofflaw Sour',
    'Rye whiskey, lemon, house grenadine, and aromatic bitters — the bar''s namesake pour.',
    'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800&q=80',
    'Rye',
    false,
    false,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000003',
    'Root Beer Old Fashioned',
    'Aged bourbon, root beer reduction, vanilla bitters, and a cloud of cedar smoke.',
    'https://images.unsplash.com/photo-1527281400683-1aae59a916a5?w=800&q=80',
    'Bourbon',
    true,
    false,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000004',
    'Lazy Bird Manhattan',
    'Rittenhouse rye, Dolin rouge, and walnut bitters — served up, always perfect.',
    'https://images.unsplash.com/photo-1527281400683-1aae59a916a5?w=800&q=80',
    'Rye',
    false,
    false,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000005',
    'Lost Lake Mai Tai',
    'Denizen aged rum, lime, orgeat, and curaçao over crushed pebble ice.',
    'https://images.unsplash.com/photo-1546171753-97d0dbd11023?w=800&q=80',
    'Rum',
    false,
    false,
    false
  ),
  (
    'b2000001-0000-4000-8000-000000000006',
    'Bee''s Knees',
    'London dry gin, fresh lemon, and local honey syrup — bright, silky, timeless.',
    'https://images.unsplash.com/photo-1551538826-4c7acaaef387?w=800&q=80',
    'Gin',
    false,
    false,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000007',
    'Paper Plane',
    'Bourbon, Aperol, Amaro Nonino, and lemon — equal parts, impeccably balanced.',
    'https://images.unsplash.com/photo-1551538826-4c7acaaef387?w=800&q=80',
    'Bourbon',
    false,
    false,
    false
  ),
  (
    'b2000001-0000-4000-8000-000000000008',
    'Three Dots and a Dash',
    'Rhum Agricole, honey, allspice, and tropical citrus — Chicago tiki at its finest.',
    'https://images.unsplash.com/photo-1546171753-97d0dbd11023?w=800&q=80',
    'Rum',
    true,
    false,
    true
  ),
  (
    'b2000001-0000-4000-8000-000000000009',
    'Aviation',
    'Gin, maraschino liqueur, crème de violette, and lemon — floral, pale, elegant.',
    'https://images.unsplash.com/photo-1514362545857-3bc165c4d737?w=800&q=80',
    'Gin',
    false,
    false,
    false
  ),
  (
    'b2000001-0000-4000-8000-000000000010',
    'Penicillin',
    'Blended scotch, lemon, honey-ginger, and an Islay float — smoky and restorative.',
    'https://images.unsplash.com/photo-1551024709-8f23be4d0087?w=800&q=80',
    'Scotch',
    false,
    false,
    false
  );

-- ---------------------------------------------------------------------------
-- Bar ↔ Cocktail links
-- ---------------------------------------------------------------------------

insert into public.bar_cocktails (bar_id, cocktail_id, is_signature) values
  ('a2000001-0000-4000-8000-000000000001', 'b2000001-0000-4000-8000-000000000001', true),
  ('a2000001-0000-4000-8000-000000000001', 'b2000001-0000-4000-8000-000000000009', false),
  ('a2000001-0000-4000-8000-000000000002', 'b2000001-0000-4000-8000-000000000002', true),
  ('a2000001-0000-4000-8000-000000000002', 'b2000001-0000-4000-8000-000000000006', false),
  ('a2000001-0000-4000-8000-000000000003', 'b2000001-0000-4000-8000-000000000003', true),
  ('a2000001-0000-4000-8000-000000000003', 'b2000001-0000-4000-8000-000000000007', false),
  ('a2000001-0000-4000-8000-000000000004', 'b2000001-0000-4000-8000-000000000004', true),
  ('a2000001-0000-4000-8000-000000000004', 'b2000001-0000-4000-8000-000000000010', false),
  ('a2000001-0000-4000-8000-000000000005', 'b2000001-0000-4000-8000-000000000005', true),
  ('a2000001-0000-4000-8000-000000000005', 'b2000001-0000-4000-8000-000000000008', false);

-- ---------------------------------------------------------------------------
-- Happy hours (3)
-- ---------------------------------------------------------------------------

insert into public.happy_hours (id, bar_id, time_range, deal_description, days_active) values
  (
    'c3000001-0000-4000-8000-000000000001',
    'a2000001-0000-4000-8000-000000000001',
    '5 – 6:30 PM',
    '$12 select aperitifs and house highballs, complimentary bar snacks',
    'Mon – Thu'
  ),
  (
    'c3000001-0000-4000-8000-000000000002',
    'a2000001-0000-4000-8000-000000000002',
    '5 – 7 PM',
    '$10 Scofflaw Sour and rotating gin classics, half-off cheese boards',
    'Mon – Fri'
  ),
  (
    'c3000001-0000-4000-8000-000000000003',
    'a2000001-0000-4000-8000-000000000005',
    '4 – 6 PM',
    'Half-off tiki punch bowls and $9 rum daiquiris before the dinner rush',
    'Tue – Fri'
  );
