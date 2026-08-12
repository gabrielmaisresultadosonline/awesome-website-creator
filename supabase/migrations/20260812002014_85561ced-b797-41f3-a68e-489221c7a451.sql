create type public.app_role as enum ('admin', 'user');

-- Profiles table to store user information
create table public.profiles (
    id uuid references auth.users(id) on delete cascade primary key,
    full_name text,
    whatsapp text,
    created_at timestamptz default now()
);

-- User roles table
create table public.user_roles (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade not null,
    role app_role not null default 'user',
    unique (user_id, role)
);

-- Subscriptions and Trials table
create table public.subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade not null,
    type text not null check (type in ('trial', 'monthly', 'semiannual', 'annual')),
    status text not null check (status in ('active', 'expired', 'pending')),
    expires_at timestamptz not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Grants
grant select, update on public.profiles to authenticated;
grant select on public.user_roles to authenticated;
grant select on public.subscriptions to authenticated;
grant all on public.profiles to service_role;
grant all on public.user_roles to service_role;
grant all on public.subscriptions to service_role;

-- RLS
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.subscriptions enable row level security;

-- Policies
create policy "Users can view their own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update their own profile" on public.profiles for update using (auth.uid() = id);

create policy "Users can view their own roles" on public.user_roles for select using (auth.uid() = user_id);

create policy "Users can view their own subscriptions" on public.subscriptions for select using (auth.uid() = user_id);

-- Security Definer for Admin checks
create or replace function public.has_role(_user_id uuid, _role app_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles
    where user_id = _user_id
      and role = _role
  )
$$;

-- Admin policies
create policy "Admins can see all profiles" on public.profiles for select using (public.has_role(auth.uid(), 'admin'));
create policy "Admins can see all roles" on public.user_roles for select using (public.has_role(auth.uid(), 'admin'));
create policy "Admins can manage all subscriptions" on public.subscriptions for all using (public.has_role(auth.uid(), 'admin'));

-- Function to handle new user signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, whatsapp)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'whatsapp');
  
  insert into public.user_roles (user_id, role)
  values (new.id, 'user');
  
  -- If trial is requested in metadata, create it
  if new.raw_user_meta_data->>'is_trial' = 'true' then
    insert into public.subscriptions (user_id, type, status, expires_at)
    values (new.id, 'trial', 'active', now() + interval '20 minutes');
  end if;
  
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
