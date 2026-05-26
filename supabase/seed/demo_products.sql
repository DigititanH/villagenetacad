-- Village NetAcad — demo product seed
--
-- Paste this into the Supabase SQL Editor and click Run. It is idempotent:
-- categories and products are upserted by `slug` so you can run it again
-- whenever you want to refresh the demo catalog without duplicating rows.
--
-- After it runs, refresh /products in the frontend to see the items.

begin;

-- ---------------------------------------------------------------------------
-- 1) Categories  (4)
-- ---------------------------------------------------------------------------
insert into public.categories (name, slug, description) values
  ('Apparel',     'apparel',     'T-shirts, hoodies and caps — wear your support.'),
  ('Drinkware',   'drinkware',   'Mugs, cups and bottles for the office, lab or classroom.'),
  ('Stationery',  'stationery',  'Notebooks, pens and stickers for every student.'),
  ('Accessories', 'accessories', 'Tote bags, lanyards and small gear with our village colors.')
on conflict (slug) do update
  set name        = excluded.name,
      description = excluded.description;

-- ---------------------------------------------------------------------------
-- 2) Products  (~15, mixed across categories, prices in cents)
-- ---------------------------------------------------------------------------
insert into public.products
  (name, slug, description, price_cents, image_url, stock, featured, active, category_id)
values
  -- Apparel
  (
    'Village NetAcad Classic T-Shirt',
    'classic-tee',
    'Soft cotton tee with the Village NetAcad logo on the chest. Every shirt funds an hour of free class time.',
    2000,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
    100, true, true,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Pullover Hoodie',
    'pullover-hoodie',
    'Warm, fleece-lined hoodie with the NetAcad mark. Perfect for chilly evening labs.',
    3500,
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
    50, true, true,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Snapback Cap',
    'snapback-cap',
    'Embroidered snapback cap. Adjustable, one-size-fits-most.',
    1500,
    'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=800',
    80, false, true,
    (select id from public.categories where slug='apparel')
  ),
  (
    'Beanie',
    'logo-beanie',
    'Knit beanie with embroidered village logo. One size, double-folded brim.',
    1200,
    'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=800',
    60, false, true,
    (select id from public.categories where slug='apparel')
  ),

  -- Drinkware
  (
    'Ceramic Coffee Mug',
    'coffee-mug',
    '11oz ceramic mug for sipping while you study. Dishwasher and microwave safe.',
    1200,
    'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800',
    150, true, true,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Stainless Steel Travel Cup',
    'travel-cup',
    'Insulated 16oz travel cup with screw-on lid. Keeps drinks hot for 6 hours.',
    1800,
    'https://images.unsplash.com/photo-1572119865084-43c285814d63?w=800',
    100, true, true,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Reusable Water Bottle',
    'water-bottle',
    'BPA-free 750ml bottle with leak-proof lid and our village logo.',
    1400,
    'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800',
    120, false, true,
    (select id from public.categories where slug='drinkware')
  ),
  (
    'Glass Tumbler',
    'glass-tumbler',
    'Borosilicate glass tumbler with silicone sleeve and bamboo lid. 350ml.',
    1600,
    'https://images.unsplash.com/photo-1610632380989-680fe40816c6?w=800',
    70, false, true,
    (select id from public.categories where slug='drinkware')
  ),

  -- Stationery
  (
    'Lined Notebook',
    'lined-notebook',
    'A5 hardcover notebook, 120 pages, perfect for lecture notes and lab logs.',
    900,
    'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=800',
    200, false, true,
    (select id from public.categories where slug='stationery')
  ),
  (
    'Sticker Pack (10 pcs)',
    'sticker-pack',
    'Vinyl stickers featuring our logo and networking icons — laptops, water bottles, you name it.',
    500,
    'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=800',
    300, true, true,
    (select id from public.categories where slug='stationery')
  ),
  (
    'Branded Ballpoint Pen',
    'logo-pen',
    'Smooth-writing blue ballpoint pen with our logo. Sold in packs of 5.',
    400,
    'https://images.unsplash.com/photo-1583485088034-697b5bc36b92?w=800',
    400, false, true,
    (select id from public.categories where slug='stationery')
  ),
  (
    'Index Card Set',
    'index-cards',
    '100 pre-ruled index cards for study sessions and lab cheat-sheets. 5 colors.',
    600,
    'https://images.unsplash.com/photo-1456406644174-8ddd4cd52a06?w=800',
    180, false, true,
    (select id from public.categories where slug='stationery')
  ),

  -- Accessories
  (
    'Canvas Tote Bag',
    'tote-bag',
    'Heavy 12oz canvas tote with reinforced straps. Carries books, laptops and groceries.',
    1300,
    'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?w=800',
    100, true, true,
    (select id from public.categories where slug='accessories')
  ),
  (
    'Lanyard with Badge Holder',
    'lanyard',
    'Branded lanyard with quick-release clip and clear ID badge holder.',
    700,
    'https://images.unsplash.com/photo-1591348122449-02525d70379b?w=800',
    180, false, true,
    (select id from public.categories where slug='accessories')
  ),
  (
    'Enamel Pin Set',
    'enamel-pins',
    'Set of 3 hard-enamel pins celebrating networking — switch, router and our village logo.',
    800,
    'https://images.unsplash.com/photo-1530021232320-687d8e3dba54?w=800',
    150, false, true,
    (select id from public.categories where slug='accessories')
  ),
  (
    'Phone Stand',
    'phone-stand',
    'Adjustable aluminium phone stand for desk video calls and tutorials.',
    1500,
    'https://images.unsplash.com/photo-1593642634443-44adaa06623a?w=800',
    90, true, true,
    (select id from public.categories where slug='accessories')
  )
on conflict (slug) do update
  set name        = excluded.name,
      description = excluded.description,
      price_cents = excluded.price_cents,
      image_url   = excluded.image_url,
      stock       = excluded.stock,
      featured    = excluded.featured,
      active      = excluded.active,
      category_id = excluded.category_id;

commit;

-- ---------------------------------------------------------------------------
-- Verify  (should show 16 products spread across 4 categories)
-- ---------------------------------------------------------------------------
select c.name as category, count(p.*) as products, sum(p.stock) as units_in_stock
from public.categories c
left join public.products p on p.category_id = c.id and p.active is true
group by c.name
order by c.name;
