-- Snaked 06: each player's board travels with their score, so the race result screen can show both boards
-- side by side, like Breakin (Lok, 19 Sep). Run once in the Supabase SQL editor (Partfinder project).
-- Nothing to edit. Until it is run the race works exactly as before, just without the boards.
-- Format: 360 characters, one per square of the 15 x 24 board, row by row:
--   .  empty   s  stone   x  stone your rival sent   b  body   h  head   a  apple

alter table public.shed_rooms add column if not exists host_grid  text;
alter table public.shed_rooms add column if not exists guest_grid text;

alter table public.shed_rooms drop constraint if exists shed_rooms_grid;
alter table public.shed_rooms add constraint shed_rooms_grid check (
  (host_grid  is null or host_grid  ~ '^[.sxbha]{360}$') and
  (guest_grid is null or guest_grid ~ '^[.sxbha]{360}$'));
