-- Snaked 05: rematch needs both players to say yes (Lok, 19 Sep). Run once in the Supabase SQL editor
-- (Partfinder project). Nothing to edit. Until it is run the game keeps the old host-only Rematch button.
-- Each player ticks their own box; when both are ticked the host starts the next round and clears them.
-- The 30-second limit runs on each phone, so no deadline column is needed.

alter table public.shed_rooms add column if not exists host_again  boolean not null default false;
alter table public.shed_rooms add column if not exists guest_again boolean not null default false;
