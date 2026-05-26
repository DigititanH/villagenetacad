-- =============================================================================
-- Village NetAcad — single-file database setup
-- =============================================================================
-- Paste this entire file into the Supabase SQL editor and click "Run".
-- It is idempotent: safe to run again later.
--
-- Order of operations:
--   1. Grant EXECUTE on has_role() to anon/authenticated/service_role
--   2. Add the 'reseller' value to the app_role enum
--   3. Let admins read every profile row
--   4. Replace generic shop seed with fundraising merch + create donations
--   5. Create the reseller_sales table + RLS
--   6. Create the reseller_applications table + RLS
--   7. Grant the test admin / reseller roles (run AFTER creating the auth users)
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. has_role() execute grants
-- -----------------------------------------------------------------------------
grant execute on function public.has_role(uuid, public.app_role)
  to anon, authenticated, service_role;


-- -----------------------------------------------------------------------------
-- 2. Extend the role enum. MUST be a top-level statement (committed before any
--    policy below references 'reseller'). Do NOT wrap this in BEGIN/COMMIT.
-- -----------------------------------------------------------------------------
alter type public.app_role add value if not exists 'reseller';


-- -----------------------------------------------------------------------------
-- 3. Admins can read all profiles (needed for /admin/users)
-- -----------------------------------------------------------------------------
drop policy if exists "Admins view all profiles" on public.profiles;
create policy "Admins view all profiles"
  on public.profiles for select
  using (public.has_role(auth.uid(), 'admin'));


-- -----------------------------------------------------------------------------
-- 4. Replace seed catalog with Village NetAcad fundraising merch
--    + add the donations table
-- -----------------------------------------------------------------------------
begin;

delete from public.cart_items;
delete from public.order_items;
delete from public.products;
delete from public.categories;

insert into public.categories (name, slug, description) values
  ('Apparel',     'apparel',     'T-shirts, hoodies and caps — wear your support.'),
  ('Drinkware',   'drinkware',   'Mugs, cups and bottles for the office, lab or classroom.'),
  ('Stationery',  'stationery',  'Notebooks, pens and stickers for every student.'),
  ('Accessories', 'accessories', 'Tote bags, lanyards and small gear with our village colors.');

insert into public.products
  (name, slug, description, price_cents, image_url, stock, featured, category_id) values
  ('Village NetAcad Classic T-Shirt', 'classic-tee',
   'Soft cotton tee with the Village NetAcad logo on the chest. Every shirt funds an hour of free class time.',
   2000, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800', 100, true,
   (select id from public.categories where slug='apparel')),
  ('Pullover Hoodie', 'pullover-hoodie',
   'Warm, fleece-lined hoodie with the NetAcad mark. Perfect for chilly evening labs.',
   3500, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800', 50, true,
   (select id from public.categories where slug='apparel')),
  ('Snapback Cap', 'snapback-cap',
   'Embroidered snapback cap. Adjustable, one-size-fits-most.',
   1500, 'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=800', 80, false,
   (select id from public.categories where slug='apparel')),
  ('Ceramic Coffee Mug', 'coffee-mug',
   '11oz ceramic mug for sipping while you study. Dishwasher and microwave safe.',
   1200, 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800', 150, true,
   (select id from public.categories where slug='drinkware')),
  ('Stainless Steel Travel Cup', 'travel-cup',
   'Insulated 16oz travel cup with screw-on lid. Keeps drinks hot for 6 hours.',
   1800, 'https://images.unsplash.com/photo-1572119865084-43c285814d63?w=800', 100, true,
   (select id from public.categories where slug='drinkware')),
  ('Reusable Water Bottle', 'water-bottle',
   'BPA-free 750ml bottle with leak-proof lid and our village logo.',
   1400, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800', 120, false,
   (select id from public.categories where slug='drinkware')),
  ('Lined Notebook', 'lined-notebook',
   'A5 hardcover notebook, 120 pages, perfect for lecture notes and lab logs.',
   900, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=800', 200, false,
   (select id from public.categories where slug='stationery')),
  ('Sticker Pack (10 pcs)', 'sticker-pack',
   'Vinyl stickers featuring our logo and networking icons — laptops, water bottles, you name it.',
   500, 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=800', 300, true,
   (select id from public.categories where slug='stationery')),
  ('Canvas Tote Bag', 'tote-bag',
   'Heavy 12oz canvas tote with reinforced straps. Carries books, laptops and groceries.',
   1300, 'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?w=800', 100, true,
   (select id from public.categories where slug='accessories')),
  ('Lanyard with Badge Holder', 'lanyard',
   'Branded lanyard with quick-release clip and clear ID badge holder.',
   700, 'https://images.unsplash.com/photo-1591348122449-02525d70379b?w=800', 180, false,
   (select id from public.categories where slug='accessories')),
  ('Enamel Pin Set', 'enamel-pins',
   'Set of 3 hard-enamel pins celebrating networking — switch, router and our village logo.',
   800, 'https://images.unsplash.com/photo-1530021232320-687d8e3dba54?w=800', 150, false,
   (select id from public.categories where slug='accessories'));

-- Donations table for the /donate page.
create table if not exists public.donations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  donor_name text,
  donor_email text,
  amount_cents integer not null check (amount_cents > 0),
  message text,
  status text not null default 'pending', -- pending | received | cancelled
  created_at timestamptz not null default now()
);

alter table public.donations enable row level security;

drop policy if exists "Anyone can submit donations" on public.donations;
create policy "Anyone can submit donations"
  on public.donations for insert
  with check (true);

drop policy if exists "Users see own donations" on public.donations;
create policy "Users see own donations"
  on public.donations for select
  using (auth.uid() is not null and auth.uid() = user_id);

drop policy if exists "Admins manage donations" on public.donations;
create policy "Admins manage donations"
  on public.donations for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));

commit;


-- -----------------------------------------------------------------------------
-- 5. reseller_sales table — offline fundraiser sales logged by approved
--    community resellers.
-- -----------------------------------------------------------------------------
create table if not exists public.reseller_sales (
  id uuid primary key default gen_random_uuid(),
  reseller_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  unit_price_cents integer not null check (unit_price_cents >= 0),
  quantity integer not null check (quantity > 0),
  total_cents integer not null check (total_cents >= 0),
  customer_name text,
  customer_contact text,
  location text,
  notes text,
  sold_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.reseller_sales enable row level security;

create index if not exists reseller_sales_reseller_id_idx
  on public.reseller_sales (reseller_id, sold_at desc);

drop policy if exists "Resellers insert own sales" on public.reseller_sales;
create policy "Resellers insert own sales"
  on public.reseller_sales for insert
  with check (
    auth.uid() = reseller_id
    and (
      public.has_role(auth.uid(), 'reseller')
      or public.has_role(auth.uid(), 'admin')
    )
  );

drop policy if exists "Resellers see own sales" on public.reseller_sales;
create policy "Resellers see own sales"
  on public.reseller_sales for select
  using (auth.uid() = reseller_id);

drop policy if exists "Resellers update own sales" on public.reseller_sales;
create policy "Resellers update own sales"
  on public.reseller_sales for update
  using (auth.uid() = reseller_id)
  with check (auth.uid() = reseller_id);

drop policy if exists "Resellers delete own sales" on public.reseller_sales;
create policy "Resellers delete own sales"
  on public.reseller_sales for delete
  using (auth.uid() = reseller_id);

drop policy if exists "Admins manage all sales" on public.reseller_sales;
create policy "Admins manage all sales"
  on public.reseller_sales for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));


-- -----------------------------------------------------------------------------
-- 6. reseller_applications — public "Apply to be a reseller" flow.
-- -----------------------------------------------------------------------------
create table if not exists public.reseller_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  location text not null,
  experience text,
  motivation text,
  status text not null default 'pending', -- pending | approved | rejected
  admin_note text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists reseller_applications_one_pending_per_user
  on public.reseller_applications (user_id)
  where status = 'pending';

create index if not exists reseller_applications_status_created_idx
  on public.reseller_applications (status, created_at desc);

drop trigger if exists reseller_applications_updated_at on public.reseller_applications;
create trigger reseller_applications_updated_at
  before update on public.reseller_applications
  for each row execute function public.set_updated_at();

alter table public.reseller_applications enable row level security;

drop policy if exists "Users submit own application" on public.reseller_applications;
create policy "Users submit own application"
  on public.reseller_applications for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users see own applications" on public.reseller_applications;
create policy "Users see own applications"
  on public.reseller_applications for select
  using (auth.uid() = user_id);

drop policy if exists "Users update own pending application" on public.reseller_applications;
create policy "Users update own pending application"
  on public.reseller_applications for update
  using (auth.uid() = user_id and status = 'pending')
  with check (auth.uid() = user_id and status = 'pending');

drop policy if exists "Admins manage applications" on public.reseller_applications;
create policy "Admins manage applications"
  on public.reseller_applications for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));


-- -----------------------------------------------------------------------------
-- 7. Auto-grant `reseller` role for anyone signing up with a staff email
--    (currently @digititan.co.za). Replaces handle_new_user() and backfills
--    existing matching users. See migration 20260511110000 for details.
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  staff_domain constant text := 'digititan.co.za';
  email_domain text;
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.email))
  on conflict (id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, 'customer')
  on conflict (user_id, role) do nothing;

  email_domain := lower(split_part(coalesce(new.email, ''), '@', 2));
  if email_domain = staff_domain then
    insert into public.user_roles (user_id, role)
    values (new.id, 'reseller')
    on conflict (user_id, role) do nothing;
  end if;

  return new;
end;
$$;

-- Make sure the trigger is wired up (the original migration created it).
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

-- Backfill existing @digititan.co.za users.
insert into public.user_roles (user_id, role)
select u.id, 'reseller'::public.app_role
from auth.users u
where lower(split_part(coalesce(u.email, ''), '@', 2)) = 'digititan.co.za'
on conflict (user_id, role) do nothing;


-- -----------------------------------------------------------------------------
-- 7b. Admin activity log (append-only; admins read all, users read/write own).
-- -----------------------------------------------------------------------------
create table if not exists public.admin_activity_log (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users (id) on delete set null,
  action       text not null,
  target_type  text,
  target_id    text,
  metadata     jsonb,
  user_agent   text,
  created_at   timestamptz not null default now()
);

create index if not exists admin_activity_log_created_idx
  on public.admin_activity_log (created_at desc);
create index if not exists admin_activity_log_user_idx
  on public.admin_activity_log (user_id, created_at desc);
create index if not exists admin_activity_log_action_idx
  on public.admin_activity_log (action, created_at desc);

alter table public.admin_activity_log enable row level security;

drop policy if exists "Users insert own activity" on public.admin_activity_log;
create policy "Users insert own activity"
  on public.admin_activity_log for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users see own activity" on public.admin_activity_log;
create policy "Users see own activity"
  on public.admin_activity_log for select
  using (auth.uid() = user_id);

drop policy if exists "Admins read all activity" on public.admin_activity_log;
create policy "Admins read all activity"
  on public.admin_activity_log for select
  using (public.has_role(auth.uid(), 'admin'));


-- -----------------------------------------------------------------------------
-- 8. Grant the test admin / reseller roles.
--    Run this AFTER you create the two auth users via the Supabase dashboard:
--      admin@netacad.test     /  Admin#netacad2026
--      reseller@netacad.test  /  Reseller#netacad2026
--    Re-running is safe (on conflict do nothing).
-- -----------------------------------------------------------------------------
insert into public.user_roles (user_id, role)
select id, 'admin'::public.app_role from auth.users
where email = 'admin@netacad.test'
on conflict do nothing;

insert into public.user_roles (user_id, role)
select id, 'reseller'::public.app_role from auth.users
where email = 'reseller@netacad.test'
on conflict do nothing;

-- Verify
select u.email,
       array_agg(r.role order by r.role) as roles
from auth.users u
left join public.user_roles r on r.user_id = u.id
where u.email in ('admin@netacad.test', 'reseller@netacad.test')
group by u.email;
