-- Enable required extensions
create extension if not exists "pgcrypto";

-- Profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  created_at timestamp with time zone default now(),
  is_pro boolean default false,
  daily_count int default 0,
  daily_count_date date default current_date
);

alter table public.profiles enable row level security;

create policy "Profiles are readable by owner" on public.profiles
  for select using (auth.uid() = id);

create policy "Profiles are insertable by owner" on public.profiles
  for insert with check (auth.uid() = id);

create policy "Profiles are updatable by owner" on public.profiles
  for update using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Repair jobs
create table if not exists public.repair_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  created_at timestamp with time zone default now(),
  category text,
  note text,
  image_path text,
  thumb_path text,
  status text,
  error_message text
);

alter table public.repair_jobs enable row level security;

create index if not exists repair_jobs_user_id_idx on public.repair_jobs(user_id);

create policy "Jobs are selectable by owner" on public.repair_jobs
  for select using (auth.uid() = user_id);

create policy "Jobs are insertable by owner" on public.repair_jobs
  for insert with check (auth.uid() = user_id);

create policy "Jobs are updatable by owner" on public.repair_jobs
  for update using (auth.uid() = user_id);

create policy "Jobs are deletable by owner" on public.repair_jobs
  for delete using (auth.uid() = user_id);

-- Diagnosis results
create table if not exists public.diagnosis_results (
  job_id uuid primary key references public.repair_jobs(id) on delete cascade,
  created_at timestamp with time zone default now(),
  issue_title text,
  confidence int,
  difficulty text,
  estimated_minutes int,
  high_level_overview jsonb,
  tools jsonb,
  parts jsonb,
  steps jsonb,
  safety_checklist jsonb,
  common_mistakes jsonb,
  verify_before_buy jsonb
);

alter table public.diagnosis_results enable row level security;

create policy "Results are selectable by owner" on public.diagnosis_results
  for select using (
    exists (
      select 1 from public.repair_jobs
      where repair_jobs.id = diagnosis_results.job_id
        and repair_jobs.user_id = auth.uid()
    )
  );

create policy "Results are insertable by owner" on public.diagnosis_results
  for insert with check (
    exists (
      select 1 from public.repair_jobs
      where repair_jobs.id = diagnosis_results.job_id
        and repair_jobs.user_id = auth.uid()
    )
  );

create policy "Results are updatable by owner" on public.diagnosis_results
  for update using (
    exists (
      select 1 from public.repair_jobs
      where repair_jobs.id = diagnosis_results.job_id
        and repair_jobs.user_id = auth.uid()
    )
  );

-- Storage bucket and policies

alter table storage.objects enable row level security;
insert into storage.buckets (id, name, public)
values ('repairs', 'repairs', false)
on conflict do nothing;

create policy "Users can access their repair images" on storage.objects
  for select
  using (
    bucket_id = 'repairs'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "Users can upload their repair images" on storage.objects
  for insert
  with check (
    bucket_id = 'repairs'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "Users can update their repair images" on storage.objects
  for update
  using (
    bucket_id = 'repairs'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "Users can delete their repair images" on storage.objects
  for delete
  using (
    bucket_id = 'repairs'
    and split_part(name, '/', 1) = auth.uid()::text
  );
