-- [03] Snaked competitive matches. Run once in the PARTFINDER Supabase project
-- (ref ekcnpuwclkjnqnntlvot), SQL editor. Safe to re-run. Needs no passphrase; independent of 01 and 02.
--
-- Model (race + attacks): two players, same apples, each on their own board. Everything one player
-- sheds lands on the other's board as stone. Each phone polls this one row about once a second
-- (Breakin's approach: plain REST, no realtime). Until this runs, "Invite a friend" says competitive
-- is not switched on yet and nothing else is affected.

create table if not exists public.shed_rooms (
  code        text primary key,                        -- 6-char invite code, no I L O 0 1
  created_at  timestamptz not null default now(),
  phase       text        not null default 'lobby',    -- lobby | live | ended
  round       integer     not null default 0,          -- +1 every match in this room (rematches)
  seed        bigint      not null default 0,          -- the apples both players get this round
  start_at    timestamptz,                             -- shared end of the 3-2-1

  host_name   text        not null,
  host_seen   timestamptz not null default now(),      -- heartbeat; stale > 15s mid-match = left
  host_len    integer     not null default 30,
  host_done   boolean     not null default false,
  host_won    boolean     not null default false,
  host_secs   numeric(6,1) not null default 0,

  guest_name  text,                                    -- null until someone joins
  guest_seen  timestamptz,
  guest_len   integer     not null default 30,
  guest_done  boolean     not null default false,
  guest_won   boolean     not null default false,
  guest_secs  numeric(6,1) not null default 0,

  constraint shed_rooms_code  check (code ~ '^[A-Z2-9]{6}$'),
  constraint shed_rooms_phase check (phase in ('lobby', 'live', 'ended')),
  constraint shed_rooms_names check (host_name ~ '^[A-Z0-9]{1,6}$' and (guest_name is null or guest_name ~ '^[A-Z0-9]{1,6}$')),
  constraint shed_rooms_len   check (host_len between 1 and 30 and guest_len between 1 and 30),
  constraint shed_rooms_secs  check (host_secs between 0 and 3600 and guest_secs between 0 and 3600)
);

alter table public.shed_rooms enable row level security;

-- Friend matches behind unguessable codes, nothing that touches the leaderboard: the anon key may
-- read, open and update rooms. No delete - a finished room just says phase = 'ended'.
drop policy if exists shed_rooms_read   on public.shed_rooms;
drop policy if exists shed_rooms_insert on public.shed_rooms;
drop policy if exists shed_rooms_update on public.shed_rooms;
create policy shed_rooms_read   on public.shed_rooms for select to anon, authenticated using (true);
create policy shed_rooms_insert on public.shed_rooms for insert to anon, authenticated with check (true);
create policy shed_rooms_update on public.shed_rooms for update to anon, authenticated using (true) with check (true);

-- Rooms are ~300 bytes each. To clear old ones now and then:
--   delete from public.shed_rooms where created_at < now() - interval '1 day';
