-- =============================================================================
-- Auto-grant the `reseller` role to anyone signing up with a Village NetAcad
-- staff email (currently @digititan.co.za).
--
-- This replaces the existing handle_new_user() trigger function so any new
-- auth.users row gets:
--   - a public.profiles row (as before)
--   - the default 'customer' role (as before)
--   - the 'reseller' role IF their email is on the staff domain
--
-- The function is SECURITY DEFINER so it can write to public.user_roles even
-- though the freshly-signed-up user has no permissions of their own. This is
-- the only safe place to enforce this rule -- a client-side check can be
-- bypassed by anyone who reads the JS.
--
-- Idempotent: safe to re-run, also backfills the role for any existing user
-- whose email matches the staff domain.
-- =============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  -- Hard-coded for clarity. To change the staff domain, edit this constant.
  staff_domain constant text := 'digititan.co.za';
  email_domain text;
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.email))
  on conflict (id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, 'customer')
  on conflict (user_id, role) do nothing;

  -- Domain check: lower-case + match the part after the final '@'.
  email_domain := lower(split_part(coalesce(new.email, ''), '@', 2));
  if email_domain = staff_domain then
    insert into public.user_roles (user_id, role)
    values (new.id, 'reseller')
    on conflict (user_id, role) do nothing;
  end if;

  return new;
end;
$$;

-- Re-create the trigger only if it doesn't already exist (the original
-- migration created it; this just guards re-runs on fresh databases).
do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'on_auth_user_created'
  ) then
    create trigger on_auth_user_created
      after insert on auth.users
      for each row execute function public.handle_new_user();
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- Backfill: any existing user with a @digititan.co.za email should get the
-- reseller role retroactively. Safe to re-run because of the unique constraint.
-- ----------------------------------------------------------------------------
insert into public.user_roles (user_id, role)
select u.id, 'reseller'::public.app_role
from auth.users u
where lower(split_part(coalesce(u.email, ''), '@', 2)) = 'digititan.co.za'
on conflict (user_id, role) do nothing;
