-- Village NetAcad — Reseller sales tracking
--
-- Adds a new app_role value 'reseller' and a reseller_sales table where
-- approved community members can log fundraiser sales they made offline
-- (market stalls, school events, door-to-door, etc.).

-- 1. Extend the role enum.
alter type public.app_role add value if not exists 'reseller';

-- 2. Sales table.
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

-- 3. RLS policies.
-- Resellers (and admins) can insert their own sales rows.
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

-- Resellers see their own sales.
drop policy if exists "Resellers see own sales" on public.reseller_sales;
create policy "Resellers see own sales"
  on public.reseller_sales for select
  using (auth.uid() = reseller_id);

-- Resellers can update / delete their own sales (typo fixes etc).
drop policy if exists "Resellers update own sales" on public.reseller_sales;
create policy "Resellers update own sales"
  on public.reseller_sales for update
  using (auth.uid() = reseller_id)
  with check (auth.uid() = reseller_id);

drop policy if exists "Resellers delete own sales" on public.reseller_sales;
create policy "Resellers delete own sales"
  on public.reseller_sales for delete
  using (auth.uid() = reseller_id);

-- Admins see / manage everything.
drop policy if exists "Admins manage all sales" on public.reseller_sales;
create policy "Admins manage all sales"
  on public.reseller_sales for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));
