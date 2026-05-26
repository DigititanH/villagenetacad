-- Village NetAcad — public "Apply to be a reseller" workflow.
--
-- Signed-in users submit an application. An admin approves it, which both
-- updates the application status AND grants the `reseller` role.

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

-- Only one *pending* application per user at a time.
create unique index if not exists reseller_applications_one_pending_per_user
  on public.reseller_applications (user_id)
  where status = 'pending';

create index if not exists reseller_applications_status_created_idx
  on public.reseller_applications (status, created_at desc);

create trigger reseller_applications_updated_at
  before update on public.reseller_applications
  for each row execute function public.set_updated_at();

alter table public.reseller_applications enable row level security;

-- A signed-in user can submit their own application.
drop policy if exists "Users submit own application" on public.reseller_applications;
create policy "Users submit own application"
  on public.reseller_applications for insert
  with check (auth.uid() = user_id);

-- A user can read their own applications (to see status).
drop policy if exists "Users see own applications" on public.reseller_applications;
create policy "Users see own applications"
  on public.reseller_applications for select
  using (auth.uid() = user_id);

-- A user can update their own *pending* application (e.g. correct typos).
drop policy if exists "Users update own pending application" on public.reseller_applications;
create policy "Users update own pending application"
  on public.reseller_applications for update
  using (auth.uid() = user_id and status = 'pending')
  with check (auth.uid() = user_id and status = 'pending');

-- Admins see / manage everything.
drop policy if exists "Admins manage applications" on public.reseller_applications;
create policy "Admins manage applications"
  on public.reseller_applications for all
  using (public.has_role(auth.uid(), 'admin'))
  with check (public.has_role(auth.uid(), 'admin'));
