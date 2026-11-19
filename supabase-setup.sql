-- Run this once in Supabase: SQL Editor > New query > paste > Run

create table profiles(
  id uuid primary key references auth.users on delete cascade,
  name text not null default '',
  role text not null default 'operator' check (role in ('admin','partner','operator')),
  is_owner boolean not null default false
);
create table entries(
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('income','expense')),
  date date not null,
  amount numeric not null check (amount > 0),
  about text default '',
  hours numeric default 0,
  bill_path text,
  created_by uuid not null default auth.uid() references profiles(id),
  created_at timestamptz default now()
);
create table settings(
  id int primary key default 1 check (id = 1),
  emi_amount numeric default 0,
  emi_day int default 1
);
insert into settings(id) values (1);
create table emi_payments(
  month text not null,
  user_id uuid not null references profiles(id) on delete cascade,
  paid_at timestamptz default now(),
  primary key (month, user_id)
);

create function my_role() returns text language sql stable security definer set search_path = public
as $$ select role from profiles where id = auth.uid() $$;

create function handle_new_user() returns trigger language plpgsql security definer set search_path = public
as $$ begin insert into profiles(id, name) values (new.id, split_part(new.email,'@',1)); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

alter table profiles enable row level security;
alter table entries enable row level security;
alter table settings enable row level security;
alter table emi_payments enable row level security;

create policy "profiles read" on profiles for select to authenticated using (true);
create policy "profiles admin update" on profiles for update to authenticated using (my_role()='admin') with check (my_role()='admin');

-- Operators see only their own entries; partners and admins see all
create policy "entries read" on entries for select to authenticated using (my_role() in ('admin','partner') or created_by = auth.uid());
create policy "entries insert" on entries for insert to authenticated with check (created_by = auth.uid());
create policy "entries delete" on entries for delete to authenticated using (my_role()='admin' or created_by = auth.uid());

create policy "settings read" on settings for select to authenticated using (my_role() in ('admin','partner'));
create policy "settings admin update" on settings for update to authenticated using (my_role()='admin') with check (my_role()='admin');

create policy "emi read" on emi_payments for select to authenticated using (my_role() in ('admin','partner'));
create policy "emi tick own" on emi_payments for insert to authenticated with check (user_id = auth.uid());
create policy "emi untick own" on emi_payments for delete to authenticated using (user_id = auth.uid());

-- Private bucket for bill photos
insert into storage.buckets (id, name, public) values ('bills','bills',false);
create policy "bills upload" on storage.objects for insert to authenticated
  with check (bucket_id='bills' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "bills view" on storage.objects for select to authenticated
  using (bucket_id='bills' and (my_role() in ('admin','partner') or (storage.foldername(name))[1] = auth.uid()::text));

-- AFTER you create your own user (Authentication > Users > Add user), make yourself admin:
-- update profiles set role='admin', is_owner=true where id = (select id from auth.users where email='YOUR-EMAIL');
