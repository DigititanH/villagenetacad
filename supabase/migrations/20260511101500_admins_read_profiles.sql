-- Let admins read every profile row, so the admin users page can show
-- everybody's full name next to their roles.
drop policy if exists "Admins view all profiles" on public.profiles;
create policy "Admins view all profiles"
  on public.profiles for select
  using (public.has_role(auth.uid(), 'admin'));
