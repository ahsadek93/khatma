-- Khatmah — multi-user (shared) khatma.
--
-- PRINCIPLE (generalises to group zikr later):
--   A shared spiritual goal completed collectively by a group. Two models:
--     * 'quran' (PARTITIONED): the goal is split into N discrete claimable
--       units (30 juz). Each unit is claimed by at most one member and
--       completed by them.  -> juz_claims
--     * 'zikr'  (ACCUMULATIVE): the goal is a target count; members append
--       conflict-free increments to a shared total.  -> zikr_contributions
--   Shared infrastructure for both: group, membership, invite/join, realtime,
--   and RLS scoped to membership.
--
-- Apply in the Supabase SQL editor. Also enable Anonymous sign-ins under
-- Authentication → Providers.

create extension if not exists "pgcrypto";

-- ── Tables ────────────────────────────────────────────────────────────────

create table if not exists public.group_khatmas (
  id           uuid primary key default gen_random_uuid(),
  kind         text not null default 'quran' check (kind in ('quran','zikr')),
  title        text not null check (char_length(title) between 1 and 120),
  total_units  int  not null default 30,          -- quran: 30 juz; zikr: target
  zikr_phrase  text,                               -- zikr only
  start_date   date,
  target_date  date,
  status       text not null default 'active'
                 check (status in ('active','completed','archived')),
  invite_code  text not null unique,
  created_by   uuid not null default auth.uid(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table if not exists public.group_members (
  id           uuid primary key default gen_random_uuid(),
  group_id     uuid not null references public.group_khatmas(id) on delete cascade,
  user_id      uuid not null default auth.uid(),
  display_name text not null,
  role         text not null default 'member' check (role in ('owner','member')),
  joined_at    timestamptz not null default now(),
  unique (group_id, user_id)
);

-- PARTITIONED units (Qur'an): one row per (group, juz).
create table if not exists public.juz_claims (
  id            uuid primary key default gen_random_uuid(),
  group_id      uuid not null references public.group_khatmas(id) on delete cascade,
  juz_number    int  not null check (juz_number between 1 and 30),
  claimed_by    uuid,                              -- member who took it; null = open
  claimed_name  text,                              -- denormalised for display
  completed     boolean not null default false,
  completed_at  timestamptz,
  updated_at    timestamptz not null default now(),
  unique (group_id, juz_number)
);

-- ACCUMULATIVE contributions (zikr): append-only, conflict-free. Reserved —
-- the zikr feature ships post-v1, but the principle and table exist now.
create table if not exists public.zikr_contributions (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references public.group_khatmas(id) on delete cascade,
  user_id     uuid not null default auth.uid(),
  amount      int  not null check (amount > 0),
  created_at  timestamptz not null default now()
);

create index if not exists juz_claims_group_idx on public.juz_claims(group_id);
create index if not exists group_members_group_idx on public.group_members(group_id);

-- ── Functions ─────────────────────────────────────────────────────────────

-- Membership check (security definer → avoids RLS recursion on group_members).
create or replace function public.is_group_member(p_group uuid)
returns boolean
language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from public.group_members m
    where m.group_id = p_group and m.user_id = auth.uid()
  );
$$;

-- Create a group, enrol the creator as owner, and (for quran) seed 30 juz.
create or replace function public.create_group_khatma(
  p_title        text,
  p_display_name text,
  p_kind         text default 'quran',
  p_total_units  int  default 30,
  p_target_date  date default null,
  p_zikr_phrase  text default null
) returns public.group_khatmas
language plpgsql security definer set search_path = public as $$
declare
  g    public.group_khatmas;
  code text;
  i    int;
begin
  code := upper(substr(md5(gen_random_uuid()::text), 1, 6));
  insert into public.group_khatmas
    (kind, title, total_units, zikr_phrase, target_date, invite_code,
     created_by, start_date)
  values
    (p_kind, p_title, p_total_units, p_zikr_phrase, p_target_date, code,
     auth.uid(), current_date)
  returning * into g;

  insert into public.group_members (group_id, user_id, display_name, role)
  values (g.id, auth.uid(), p_display_name, 'owner');

  if p_kind = 'quran' then
    for i in 1..least(p_total_units, 30) loop
      insert into public.juz_claims (group_id, juz_number) values (g.id, i);
    end loop;
  end if;

  return g;
end;
$$;

-- Join a group by its invite code (validates the code; enrols the caller).
create or replace function public.join_group_khatma(
  p_code text,
  p_display_name text
) returns uuid
language plpgsql security definer set search_path = public as $$
declare g_id uuid;
begin
  select id into g_id from public.group_khatmas
  where invite_code = upper(p_code) and status <> 'archived';
  if g_id is null then raise exception 'invalid_invite_code'; end if;

  insert into public.group_members (group_id, user_id, display_name)
  values (g_id, auth.uid(), p_display_name)
  on conflict (group_id, user_id) do update set display_name = excluded.display_name;

  return g_id;
end;
$$;

-- ── Row Level Security ────────────────────────────────────────────────────

alter table public.group_khatmas      enable row level security;
alter table public.group_members      enable row level security;
alter table public.juz_claims         enable row level security;
alter table public.zikr_contributions enable row level security;

-- group_khatmas: members read; creator inserts; members update.
create policy gk_select on public.group_khatmas
  for select using (public.is_group_member(id));
create policy gk_insert on public.group_khatmas
  for insert with check (created_by = auth.uid());
create policy gk_update on public.group_khatmas
  for update using (public.is_group_member(id));

-- group_members: members read the roster; a user manages only their own row.
create policy gm_select on public.group_members
  for select using (public.is_group_member(group_id));
create policy gm_insert on public.group_members
  for insert with check (user_id = auth.uid());
create policy gm_delete on public.group_members
  for delete using (user_id = auth.uid());

-- juz_claims: members read; members may only touch open units or their own
-- (you can claim an unclaimed juz, complete/release yours, not steal others').
create policy jc_select on public.juz_claims
  for select using (public.is_group_member(group_id));
create policy jc_update on public.juz_claims
  for update using (
    public.is_group_member(group_id)
    and (claimed_by is null or claimed_by = auth.uid())
  )
  with check (claimed_by is null or claimed_by = auth.uid());

-- zikr_contributions: members read & append their own.
create policy zc_select on public.zikr_contributions
  for select using (public.is_group_member(group_id));
create policy zc_insert on public.zikr_contributions
  for insert with check (public.is_group_member(group_id) and user_id = auth.uid());

-- ── Realtime ──────────────────────────────────────────────────────────────
alter publication supabase_realtime add table public.group_khatmas;
alter publication supabase_realtime add table public.group_members;
alter publication supabase_realtime add table public.juz_claims;
alter publication supabase_realtime add table public.zikr_contributions;
