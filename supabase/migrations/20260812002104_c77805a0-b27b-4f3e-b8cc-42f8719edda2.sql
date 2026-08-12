-- Create a dedicated schema for internal security definer functions
create schema if not exists auth_internal;

-- Move the functions to the new schema
alter function public.has_role(uuid, app_role) set schema auth_internal;
alter function public.handle_new_user() set schema auth_internal;

-- Re-point the trigger
drop trigger on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure auth_internal.handle_new_user();

-- Update the RLS policy to use the new schema path
drop policy "Admins can see all profiles" on public.profiles;
create policy "Admins can see all profiles" on public.profiles for select using (auth_internal.has_role(auth.uid(), 'admin'));

drop policy "Admins can see all roles" on public.user_roles;
create policy "Admins can see all roles" on public.user_roles for select using (auth_internal.has_role(auth.uid(), 'admin'));

drop policy "Admins can manage all subscriptions" on public.subscriptions;
create policy "Admins can manage all subscriptions" on public.subscriptions for all using (auth_internal.has_role(auth.uid(), 'admin'));
