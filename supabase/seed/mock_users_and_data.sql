-- =============================================================================
-- Village NetAcad — mock users, roles and demo data
-- =============================================================================
-- Run this AFTER:
--   1. supabase/setup_all.sql has been run (creates the tables)
--   2. The seven test users have been created via the Supabase dashboard
--      (Authentication → Users → Add user, with "Auto Confirm User" checked).
--
-- Test accounts (emails referenced below):
--   admin@netacad.test         Admin#netacad2026
--   reseller1@netacad.test     Reseller1#netacad2026
--   reseller2@netacad.test     Reseller2#netacad2026
--   customer1@netacad.test     Customer1#netacad2026
--   customer2@netacad.test     Customer2#netacad2026
--   applicant@netacad.test     Applicant#netacad2026
--   rejected@netacad.test      Rejected#netacad2026
--
-- Safe to run multiple times — every insert is guarded.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Friendly display names on profiles
-- -----------------------------------------------------------------------------
update public.profiles set full_name = x.name
from (values
  ('admin@netacad.test',     'Site Admin'),
  ('reseller1@netacad.test', 'Thabo Mokoena'),
  ('reseller2@netacad.test', 'Nomvula Ndlovu'),
  ('customer1@netacad.test', 'Lerato Khumalo'),
  ('customer2@netacad.test', 'Sipho Dlamini'),
  ('applicant@netacad.test', 'Aisha Patel'),
  ('rejected@netacad.test',  'Bongani Zulu')
) as x(email, name)
join auth.users u on u.email = x.email
where public.profiles.id = u.id;


-- -----------------------------------------------------------------------------
-- 2. Role grants
-- -----------------------------------------------------------------------------
insert into public.user_roles (user_id, role)
select id, 'admin'::public.app_role from auth.users
where email = 'admin@netacad.test'
on conflict do nothing;

insert into public.user_roles (user_id, role)
select id, 'reseller'::public.app_role from auth.users
where email in ('reseller1@netacad.test', 'reseller2@netacad.test')
on conflict do nothing;


-- -----------------------------------------------------------------------------
-- 3. Reseller applications (one pending, one rejected)
-- -----------------------------------------------------------------------------
insert into public.reseller_applications
  (user_id, full_name, phone, location, experience, motivation, status)
select u.id, 'Aisha Patel', '+27 82 555 0144',
  'My village market & school events',
  'Sold school raffle tickets every year. Helped my aunt run a snack stall on weekends.',
  'I want every kid in the village to have the same shot at free networking classes that I did.',
  'pending'
from auth.users u
where u.email = 'applicant@netacad.test'
  and not exists (
    select 1 from public.reseller_applications a
    where a.user_id = u.id and a.status = 'pending'
  );

insert into public.reseller_applications
  (user_id, full_name, phone, location, experience, motivation, status, admin_note, reviewed_at)
select u.id, 'Bongani Zulu', '+27 71 222 9988',
  'Door-to-door in my neighborhood',
  'No prior selling experience.',
  'I want to help raise money.',
  'rejected',
  'Please attend the next reseller orientation session and apply again afterward.',
  now() - interval '2 days'
from auth.users u
where u.email = 'rejected@netacad.test'
  and not exists (
    select 1 from public.reseller_applications a
    where a.user_id = u.id and a.status = 'rejected'
  );


-- -----------------------------------------------------------------------------
-- 4. Donations (pending / received / cancelled mix)
-- -----------------------------------------------------------------------------
-- One anonymous donation
insert into public.donations
  (donor_name, donor_email, amount_cents, message, status, created_at)
select 'Anonymous well-wisher', null, 5000,
  'Keep doing the great work!', 'received', now() - interval '6 days'
where not exists (
  select 1 from public.donations
  where donor_name = 'Anonymous well-wisher' and amount_cents = 5000
);

-- A signed-in customer donates
insert into public.donations
  (user_id, donor_name, donor_email, amount_cents, message, status, created_at)
select u.id, 'Lerato Khumalo', u.email, 2500,
  'For the next lab kit.', 'received', now() - interval '4 days'
from auth.users u
where u.email = 'customer1@netacad.test'
  and not exists (
    select 1 from public.donations
    where user_id = u.id and amount_cents = 2500
  );

insert into public.donations
  (user_id, donor_name, donor_email, amount_cents, message, status, created_at)
select u.id, 'Sipho Dlamini', u.email, 10000,
  'Pay it forward — I learned networking here in 2024.', 'pending',
  now() - interval '1 days'
from auth.users u
where u.email = 'customer2@netacad.test'
  and not exists (
    select 1 from public.donations
    where user_id = u.id and amount_cents = 10000
  );

-- A cancelled one for visual variety
insert into public.donations
  (donor_name, donor_email, amount_cents, message, status, created_at)
select 'Test Donor', 'test.donor@example.com', 1500,
  null, 'cancelled', now() - interval '8 days'
where not exists (
  select 1 from public.donations
  where donor_email = 'test.donor@example.com'
);


-- -----------------------------------------------------------------------------
-- 5. Reseller sales — populate the dashboards with realistic data
-- -----------------------------------------------------------------------------
-- Helper view via WITH to look up users + products by stable keys.
with
  reseller1 as (
    select id from auth.users where email = 'reseller1@netacad.test'
  ),
  reseller2 as (
    select id from auth.users where email = 'reseller2@netacad.test'
  )
insert into public.reseller_sales (
  reseller_id, product_id, product_name, unit_price_cents, quantity, total_cents,
  customer_name, customer_contact, location, notes, sold_at
)
select x.reseller_id, p.id, p.name, p.price_cents, x.qty, p.price_cents * x.qty,
       x.customer_name, x.customer_contact, x.location, x.notes, x.sold_at
from (values
  -- Reseller 1 — busy at the school market
  ((select id from reseller1), 'classic-tee',    2, 'Mrs. Dlamini',   '+27 82 111 2222', 'School market day',   'Paid cash. Wants a size L next week.', now() - interval '11 days'),
  ((select id from reseller1), 'coffee-mug',     3, 'Walk-in',        null,              'School market day',   null,                                   now() - interval '11 days'),
  ((select id from reseller1), 'snapback-cap',   1, 'Thabo M.',       null,              'Family event',        'Gift for nephew.',                     now() - interval '9 days'),
  ((select id from reseller1), 'tote-bag',       2, 'Walk-in',        null,              'Church bazaar',       null,                                   now() - interval '7 days'),
  ((select id from reseller1), 'sticker-pack',   5, 'Lerato N.',      null,              'School market day',   'Bulk for her classroom.',              now() - interval '5 days'),
  ((select id from reseller1), 'coffee-mug',     2, 'Sipho M.',       '+27 79 555 0102', 'Community hall',      null,                                   now() - interval '3 days'),
  ((select id from reseller1), 'pullover-hoodie',1, 'Aunt Vivian',    null,              'Family event',        'Will pay end of month.',               now() - interval '2 days'),

  -- Reseller 2 — newer, smaller numbers
  ((select id from reseller2), 'lanyard',        2, 'Bra Joe',        null,              'Church bazaar',       null,                                   now() - interval '6 days'),
  ((select id from reseller2), 'enamel-pins',    1, 'Walk-in',        null,              'Door-to-door',        null,                                   now() - interval '4 days'),
  ((select id from reseller2), 'water-bottle',   3, 'Nana Khethiwe',  '+27 82 333 4444', 'Sunday market',       'Asked about hoodies for next time.',   now() - interval '1 days')
) as x(reseller_id, slug, qty, customer_name, customer_contact, location, notes, sold_at)
join public.products p on p.slug = x.slug
where x.reseller_id is not null
  and not exists (
    select 1 from public.reseller_sales s
    where s.reseller_id = x.reseller_id
      and s.product_name = p.name
      and s.quantity = x.qty
      and date_trunc('day', s.sold_at) = date_trunc('day', x.sold_at)
  );


-- -----------------------------------------------------------------------------
-- 6. Verify
-- -----------------------------------------------------------------------------
select 'users + roles' as section,
       u.email,
       coalesce(p.full_name, '(no name)') as profile_name,
       array_agg(r.role order by r.role) filter (where r.role is not null) as roles
from auth.users u
left join public.profiles p on p.id = u.id
left join public.user_roles r on r.user_id = u.id
where u.email like '%@netacad.test'
group by u.email, p.full_name
order by u.email;

select 'donations'        as section, status, count(*), sum(amount_cents) / 100.0 as total_dollars from public.donations group by status;
select 'reseller sales'   as section, count(*) as rows, sum(total_cents) / 100.0 as total_dollars from public.reseller_sales;
select 'applications'     as section, status, count(*) from public.reseller_applications group by status;
