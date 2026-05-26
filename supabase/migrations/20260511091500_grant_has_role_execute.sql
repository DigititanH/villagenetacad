-- The has_role() function is referenced from several RLS policies
-- (products, orders, etc.). It's SECURITY DEFINER, but Postgres still
-- requires the calling role to have EXECUTE on it. Grant that to the
-- standard Supabase roles so anon / authenticated users can evaluate
-- policies that call has_role().
grant execute on function public.has_role(uuid, public.app_role) to anon, authenticated, service_role;
