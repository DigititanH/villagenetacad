-- =============================================================================
-- Admin activity log.
--
-- Captures meaningful actions performed by signed-in staff (login, role
-- changes, application approvals, etc). All writes go through the frontend
-- helper logActivity() with auth.uid() implicit via RLS.
-- =============================================================================

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

-- Anyone signed in can insert a row for themselves. We intentionally don't
-- let users insert with someone else's user_id.
drop policy if exists "Users insert own activity" on public.admin_activity_log;
create policy "Users insert own activity"
  on public.admin_activity_log for insert
  with check (auth.uid() = user_id);

-- Users can see their own rows (handy if we ever surface "my recent actions"
-- on a profile page).
drop policy if exists "Users see own activity" on public.admin_activity_log;
create policy "Users see own activity"
  on public.admin_activity_log for select
  using (auth.uid() = user_id);

-- Admins can read everything.
drop policy if exists "Admins read all activity" on public.admin_activity_log;
create policy "Admins read all activity"
  on public.admin_activity_log for select
  using (public.has_role(auth.uid(), 'admin'));

-- Activity log is append-only; nobody updates or deletes. (No update/delete
-- policies = denied for everyone, which is what we want.)
