-- Add username to profiles and wire signup metadata

alter table public.profiles
  add column if not exists username text;

create unique index if not exists profiles_username_unique_idx
  on public.profiles (lower(username))
  where username is not null;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta_username text;
  meta_display_name text;
begin
  meta_username := nullif(trim(new.raw_user_meta_data ->> 'username'), '');
  meta_display_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''),
    meta_username,
    split_part(new.email, '@', 1)
  );

  insert into public.profiles (id, display_name, username)
  values (new.id, meta_display_name, meta_username);

  return new;
end;
$$;
