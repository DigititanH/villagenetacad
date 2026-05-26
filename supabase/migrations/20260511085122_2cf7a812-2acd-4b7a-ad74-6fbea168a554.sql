
-- Roles
create type public.app_role as enum ('admin', 'customer');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role app_role not null default 'customer',
  created_at timestamptz not null default now(),
  unique (user_id, role)
);
alter table public.user_roles enable row level security;

create or replace function public.has_role(_user_id uuid, _role app_role)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.user_roles where user_id = _user_id and role = _role)
$$;

-- Auto-create profile + default role on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email));
  insert into public.user_roles (user_id, role) values (new.id, 'customer');
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Updated_at helper
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

-- Categories
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  created_at timestamptz not null default now()
);
alter table public.categories enable row level security;

-- Products
create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  price_cents integer not null check (price_cents >= 0),
  image_url text,
  stock integer not null default 0,
  category_id uuid references public.categories(id) on delete set null,
  featured boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.products enable row level security;
create trigger products_updated_at before update on public.products
  for each row execute function public.set_updated_at();

-- Orders
create type public.order_status as enum ('pending','paid','shipped','delivered','cancelled');

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status order_status not null default 'pending',
  total_cents integer not null default 0,
  email text,
  full_name text,
  address_line1 text,
  address_line2 text,
  city text,
  postal_code text,
  country text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.orders enable row level security;
create trigger orders_updated_at before update on public.orders
  for each row execute function public.set_updated_at();

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  product_image text,
  unit_price_cents integer not null,
  quantity integer not null check (quantity > 0),
  created_at timestamptz not null default now()
);
alter table public.order_items enable row level security;

-- Cart
create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);
alter table public.cart_items enable row level security;

-- RLS Policies
-- profiles
create policy "Profiles viewable by owner" on public.profiles for select using (auth.uid() = id);
create policy "Profiles updatable by owner" on public.profiles for update using (auth.uid() = id);

-- user_roles
create policy "Users see own roles" on public.user_roles for select using (auth.uid() = user_id);
create policy "Admins see all roles" on public.user_roles for select using (public.has_role(auth.uid(), 'admin'));
create policy "Admins manage roles" on public.user_roles for all using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));

-- categories: public read, admin write
create policy "Categories public read" on public.categories for select using (true);
create policy "Admins manage categories" on public.categories for all using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));

-- products: public read of active, admin manage
create policy "Products public read" on public.products for select using (active = true or public.has_role(auth.uid(), 'admin'));
create policy "Admins manage products" on public.products for all using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));

-- orders: user sees own, admin sees all
create policy "Users view own orders" on public.orders for select using (auth.uid() = user_id);
create policy "Users insert own orders" on public.orders for insert with check (auth.uid() = user_id);
create policy "Admins view all orders" on public.orders for select using (public.has_role(auth.uid(), 'admin'));
create policy "Admins update orders" on public.orders for update using (public.has_role(auth.uid(), 'admin'));

-- order_items: user sees if they own parent order, admin sees all
create policy "Users view own order items" on public.order_items for select using (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
create policy "Users insert own order items" on public.order_items for insert with check (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
create policy "Admins view all order items" on public.order_items for select using (public.has_role(auth.uid(), 'admin'));

-- cart_items: user manages own
create policy "Users manage own cart" on public.cart_items for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Seed data
insert into public.categories (name, slug, description) values
  ('Electronics','electronics','Phones, laptops, audio and more'),
  ('Home & Kitchen','home-kitchen','Appliances and homeware'),
  ('Fashion','fashion','Clothing and accessories'),
  ('Books','books','Bestsellers and classics');

insert into public.products (name, slug, description, price_cents, image_url, stock, featured, category_id) values
  ('Wireless Noise-Cancelling Headphones','wireless-headphones','Premium over-ear headphones with 40h battery and active noise cancellation.', 24999, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800', 50, true, (select id from public.categories where slug='electronics')),
  ('Smart 4K TV 55"','smart-tv-55','Crystal-clear 4K HDR display with built-in streaming.', 69999, 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800', 20, true, (select id from public.categories where slug='electronics')),
  ('Espresso Machine Pro','espresso-pro','Barista-grade espresso at home with milk frother.', 39999, 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800', 30, true, (select id from public.categories where slug='home-kitchen')),
  ('Ergonomic Office Chair','office-chair','Mesh back, lumbar support, adjustable armrests.', 19999, 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=800', 40, false, (select id from public.categories where slug='home-kitchen')),
  ('Classic Leather Jacket','leather-jacket','Genuine leather, timeless cut.', 17999, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800', 25, true, (select id from public.categories where slug='fashion')),
  ('Running Sneakers','running-sneakers','Lightweight, breathable, made for distance.', 8999, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800', 80, false, (select id from public.categories where slug='fashion')),
  ('The Pragmatic Programmer','pragmatic-programmer','A modern classic for software craftsmen.', 3499, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800', 100, false, (select id from public.categories where slug='books')),
  ('Atomic Habits','atomic-habits','Tiny changes, remarkable results.', 2499, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800', 100, true, (select id from public.categories where slug='books'));
