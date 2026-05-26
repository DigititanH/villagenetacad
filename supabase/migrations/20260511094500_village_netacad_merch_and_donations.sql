-- Village NetAcad — replace generic shop seed with fundraising merch
-- and add a `donations` table for the /donate page.
--
-- Safe to run on the existing project: clears prior products / categories
-- and re-seeds them with merch items. cart_items and order_items reference
-- products with ON DELETE CASCADE / SET NULL so they will tidy up too.

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

insert into public.products (name, slug, description, price_cents, image_url, stock, featured, category_id) values
  (
    'Village NetAcad Classic T-Shirt',
    'classic-tee',
    'Soft cotton tee with the Village NetAcad logo on the chest. Every shirt funds an hour of free class time.',
    2000,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
    100,
    true,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Pullover Hoodie',
    'pullover-hoodie',
    'Warm, fleece-lined hoodie with the NetAcad mark. Perfect for chilly evening labs.',
    3500,
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
    50,
    true,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Snapback Cap',
    'snapback-cap',
    'Embroidered snapback cap. Adjustable, one-size-fits-most.',
    1500,
    'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=800',
    80,
    false,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Ceramic Coffee Mug',
    'coffee-mug',
    '11oz ceramic mug for sipping while you study. Dishwasher and microwave safe.',
    1200,
    'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800',
    150,
    true,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Stainless Steel Travel Cup',
    'travel-cup',
    'Insulated 16oz travel cup with screw-on lid. Keeps drinks hot for 6 hours.',
    1800,
    'https://images.unsplash.com/photo-1572119865084-43c285814d63?w=800',
    100,
    true,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Reusable Water Bottle',
    'water-bottle',
    'BPA-free 750ml bottle with leak-proof lid and our village logo.',
    1400,
    'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800',
    120,
    false,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Lined Notebook',
    'lined-notebook',
    'A5 hardcover notebook, 120 pages, perfect for lecture notes and lab logs.',
    900,
    'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=800',
    200,
    false,
    (select id from public.categories where slug='stationery')
  ),
  (
    'Sticker Pack (10 pcs)',
    'sticker-pack',
    'Vinyl stickers featuring our logo and networking icons — laptops, water bottles, you name it.',
    500,
    'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=800',
    300,
    true,
    (select id from public.categories where slug='stationery')
  ),
  (
    'Canvas Tote Bag',
    'tote-bag',
    'Heavy 12oz canvas tote with reinforced straps. Carries books, laptops and groceries.',
    1300,
    'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?w=800',
    100,
    true,
    (select id from public.categories where slug='accessories')
  ),
  (
    'Lanyard with Badge Holder',
    'lanyard',
    'Branded lanyard with quick-release clip and clear ID badge holder.',
    700,
    'https://images.unsplash.com/photo-1591348122449-02525d70379b?w=800',
    180,
    false,
    (select id from public.categories where slug='accessories')
  ),
  (
    'Enamel Pin Set',
    'enamel-pins',
    'Set of 3 hard-enamel pins celebrating networking — switch, router and our village logo.',
    800,
    'https://images.unsplash.com/photo-1530021232320-687d8e3dba54?w=800',
    150,
    false,
    (select id from public.categories where slug='accessories')
  );

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

-- Anyone (including anonymous visitors) may submit a donation.
drop policy if exists "Anyone can submit donations" on public.donations;
create policy "Anyone can submit donations"
  on public.donations for insert
  with check (true);

-- Signed-in users see their own donations.
drop policy if exists "Users see own donations" on public.donations;
create policy "Users see own donations"
  on public.donations for select
  using (auth.uid() is not null and auth.uid() = user_id);

-- Admins see and manage all donations.
drop policy if exists "Admins manage donations" on public.donations;
create policy "Admins manage donations"
  on public.donations for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));

commit;
