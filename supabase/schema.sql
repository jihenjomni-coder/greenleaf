-- greenleaf Supabase schema: plants + watering_log + 8 sample plants
-- Run this script in your Supabase project's SQL Editor.

create extension if not exists pgcrypto;

-- 1. Plants table
create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text not null default '🌿',
  room text not null,
  water_every_days integer not null check (water_every_days > 0),
  last_watered timestamptz not null default now(),
  sunlight text not null default 'Bright indirect',
  care_note text not null default '',
  created_at timestamptz not null default now()
);

-- 2. Watering log table
create table if not exists public.watering_log (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references public.plants(id) on delete cascade,
  watered_at timestamptz not null default now(),
  note text
);

create index if not exists watering_log_plant_id_idx
  on public.watering_log (plant_id, watered_at desc);

-- Enable Row Level Security and allow public/anon access for the app
alter table public.plants enable row level security;
alter table public.watering_log enable row level security;

drop policy if exists "Allow all access to plants" on public.plants;
create policy "Allow all access to plants"
  on public.plants
  for all
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "Allow all access to watering_log" on public.watering_log;
create policy "Allow all access to watering_log"
  on public.watering_log
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.plants to anon, authenticated;
grant select, insert, update, delete on public.watering_log to anon, authenticated;

-- 3. Seed the 8 sample plants (only if plants table is currently empty)
insert into public.plants (name, emoji, room, water_every_days, last_watered, sunlight, care_note)
select * from (
  values
    (
      'Money Plant',
      '🍀',
      'Living Room',
      3,
      now() - interval '3 days',
      'Bright indirect',
      'Loves gentle morning light and trailing from a bright shelf. Let the top inch of soil dry slightly between waterings.'
    ),
    (
      'Aloe Vera',
      '🌿',
      'Sunny Window',
      10,
      now() - interval '6 days',
      'Full sun',
      'Soak deeply and let the soil dry out completely before watering again. Great on a warm windowsill.'
    ),
    (
      'Snake Plant',
      '🎍',
      'Bedroom',
      14,
      now() - interval '7 days',
      'Low to bright',
      'Thrives on gentle neglect and purifies bedroom air. Avoid soggy roots by watering sparingly.'
    ),
    (
      'Tulsi',
      '🌱',
      'Balcony',
      2,
      now() - interval '2 days',
      'Full sun',
      'Enjoys warm sunshine and steady moisture. Pinch off flower spikes occasionally to encourage lush, fragrant leaves.'
    ),
    (
      'Rose',
      '🌹',
      'Balcony',
      2,
      now() - interval '2 days',
      'Full sun',
      'Water right at the base in the morning to keep foliage fresh and encourage vibrant blooms.'
    ),
    (
      'Mint',
      '🍃',
      'Kitchen',
      1,
      now() - interval '1 day',
      'Bright indirect',
      'Loves consistently damp soil and regular harvesting. Snip the top stems to keep it bushy and aromatic.'
    ),
    (
      'Peace Lily',
      '🌼',
      'Living Room',
      4,
      now() - interval '4 days',
      'Low to bright',
      'Droops slightly when thirsty and perks right back up after a drink. Mist leaves for a happy tropical glow.'
    ),
    (
      'Cactus',
      '🌵',
      'Study Desk',
      14,
      now() - interval '5 days',
      'Full sun',
      'Needs plenty of light and very little water. Use a pot with a drainage hole so roots stay dry and strong.'
    )
) as seed(name, emoji, room, water_every_days, last_watered, sunlight, care_note)
where not exists (select 1 from public.plants);
