-- [02] Snaked shared leaderboard. Run once in the PARTFINDER Supabase project
-- (ref ekcnpuwclkjnqnntlvot, same project as Breakin's tables), SQL editor. Safe to re-run.
-- Needs no passphrase and does not depend on 01-inbox.sql.
--
-- Until this runs, the game still works: the board shows this device's own runs and a saved run
-- says it could not reach the leaderboard.
--
-- Ranking (applied by the client): any win beats any loss; wins by fastest time;
-- losses by fewest pieces left, then fastest time.

create table if not exists public.shed_scores (
  id         uuid primary key default gen_random_uuid(),
  name       text        not null,
  won        boolean     not null,
  len        integer     not null,             -- pieces left when the run ended (1 on a win)
  apples     integer     not null,
  secs       numeric(6,1) not null,
  ua         text,
  created_at timestamptz not null default now(),
  constraint shed_sc_name   check (name ~ '^[A-Z0-9]{1,6}$'),
  constraint shed_sc_len    check (len between 1 and 30),
  constraint shed_sc_apples check (apples between 1 and 16),
  constraint shed_sc_secs   check (secs between 0 and 3600),
  constraint shed_sc_ua     check (char_length(coalesce(ua,'')) <= 300)
);

create index if not exists shed_scores_rank_idx on public.shed_scores (won desc, len asc, secs asc);
create index if not exists shed_scores_day_idx  on public.shed_scores (created_at);

alter table public.shed_scores enable row level security;
drop policy if exists shed_sc_read   on public.shed_scores;
drop policy if exists shed_sc_insert on public.shed_scores;
create policy shed_sc_read   on public.shed_scores for select to anon, authenticated using (true);
create policy shed_sc_insert on public.shed_scores for insert to anon, authenticated with check (true);   -- the guard below does the checking

-- Sanity filter against hand-made POSTs, not an anti-bot system (same stance as Breakin's 06).
-- The fixed rules pin length to apples: start 30, shed 2 per apple, never below 1, and the 16th apple
-- (eaten at length 1) is the win. Every move takes at least 60ms, and every apple costs at least one move.
create or replace function public.shed_scores_guard()
returns trigger language plpgsql as $$
declare recent int;
begin
  if new.won then
    if new.apples <> 16 or new.len <> 1 then raise exception 'bad win'; end if;
  elsif new.apples > 15 or new.len <> greatest(1, 30 - 2 * new.apples) then
    raise exception 'length/apples mismatch';
  end if;
  -- Real wins take ~24s and no bot run has ever finished under 10s, so these floors never refuse an honest run
  -- (the old apples * 0.06 floor let a made-up 1-second win onto the all-time board).
  if new.won and new.secs < 5 then raise exception 'too fast'; end if;
  if new.secs < new.apples * 0.3 then raise exception 'too fast'; end if;
  -- Same ban list as the game (NAME_BAN / NAME_BAN_EXACT in index.html) - keep the two in step.
  if new.name ~ '(NIGG|N1GG|FUCK|SHIT|CUNT|FAGG|KIKE|CHINK|TRANNY|WHORE|HITLER|RETARD)'
     or new.name ~ '^(RAPE|NAZI|FAG|SPIC|COON|GOOK|TWAT|CUM)$' then
    raise exception 'name not allowed';
  end if;
  select count(*) into recent from public.shed_scores
    where name = new.name and created_at > now() - interval '60 seconds';
  if recent >= 30 then raise exception 'too many scores too fast'; end if;
  new.ua := left(coalesce(new.ua, ''), 300);
  new.created_at := now();
  return new;
end $$;

drop trigger if exists shed_scores_guard on public.shed_scores;
create trigger shed_scores_guard before insert on public.shed_scores
  for each row execute function public.shed_scores_guard();

-- To remove a bad row later:  delete from public.shed_scores where name = 'XXXXXX';

-- Self-test: every insert below is rolled back, so nothing ever lands on the public board.
-- Running this file ends with 'guard self-test passed' in the messages, or an error naming the case that failed.
do $$
declare got text;
  cases text[][] := array[
    -- name,     won,     len,  apples, secs,  expect
    ['TEST1',    'true',  '1',  '16',   '1.0', 'too fast'],
    ['TEST2',    'true',  '1',  '16',   '4.9', 'too fast'],
    ['TEST3',    'false', '1',  '15',   '2.0', 'too fast'],
    ['XFUCKX',   'true',  '1',  '16',   '30',  'name not allowed'],
    ['NAZI',     'false', '28', '1',    '9',   'name not allowed'],
    ['NAZIS',    'false', '28', '1',    '9',   'ok'],
    ['TEST4',    'true',  '1',  '16',   '10.0','ok'],
    ['TEST5',    'false', '4',  '13',   '12',  'ok'],
    ['TEST6',    'true',  '2',  '16',   '30',  'bad win']];
begin
  for i in 1 .. array_length(cases, 1) loop
    begin
      insert into public.shed_scores (name, won, len, apples, secs)
        values (cases[i][1], cases[i][2]::boolean, cases[i][3]::int, cases[i][4]::int, cases[i][5]::numeric);
      raise exception 'ok';                                  -- undo the row that got through
    exception when others then got := sqlerrm;
    end;
    if got <> cases[i][6] then
      raise exception 'guard self-test FAILED on %: expected %, got %', cases[i][1], cases[i][6], got;
    end if;
  end loop;
  raise notice 'guard self-test passed';
end $$;

