-- Grant the right roles to the two mock test users.
--
-- Run this AFTER you create the two auth users (see chat instructions).
-- Safe to run multiple times — uses `on conflict do nothing` and looks
-- the users up by email.

-- Admin
insert into public.user_roles (user_id, role)
select id, 'admin'::public.app_role
from auth.users
where email = 'admin@netacad.test'
on conflict do nothing;

-- Reseller
insert into public.user_roles (user_id, role)
select id, 'reseller'::public.app_role
from auth.users
where email = 'reseller@netacad.test'
on conflict do nothing;

-- Real admin (Village NetAcad owner)
insert into public.user_roles (user_id, role)
select id, 'admin'::public.app_role
from auth.users
where email = 'ditebogom@digititan.co.za'
on conflict do nothing;

-- Verify
select u.email, array_agg(r.role order by r.role) as roles
from auth.users u
left join public.user_roles r on r.user_id = u.id
where u.email in (
  'admin@netacad.test',
  'reseller@netacad.test',
  'ditebogom@digititan.co.za'
)
group by u.email;
