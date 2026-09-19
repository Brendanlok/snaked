-- Snaked 04: admin tool for leaderboard rows (list + delete one), for Lok and work sessions.
-- Run once in the Supabase SQL editor (Partfinder project). Nothing to edit: it reuses the passphrase
-- already inside shed_admin (01-inbox.sql), so the passphrase never appears in this file.
--   list:    select public.shed_admin_scores('list',   '<passphrase>');
--   delete:  select public.shed_admin_scores('delete', '<passphrase>', '<row id from list>');

create or replace function public.shed_admin_scores(action text, secret text, target uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare gone jsonb;
begin
  -- ponytail: shed_admin's 'stats' answers ok=true only for the right passphrase, so it doubles as the check
  if (public.shed_admin('stats', secret) ->> 'ok') is distinct from 'true' then
    return jsonb_build_object('ok', false, 'error', 'bad passphrase');
  end if;

  if action = 'list' then
    return coalesce((select jsonb_agg(row_to_json(t)) from (
      select id,name,won,len,apples,secs,ua,created_at from shed_scores order by created_at desc limit 100) t), '[]'::jsonb);
  elsif action = 'delete' then
    with d as (delete from shed_scores where id = target returning id,name,won,len,secs,created_at)
    select coalesce(jsonb_agg(row_to_json(d)), '[]'::jsonb) into gone from d;
    return jsonb_build_object('ok', true, 'deleted', gone);
  else
    return jsonb_build_object('ok', false, 'error', 'unknown action');
  end if;
end $$;

revoke all on function public.shed_admin_scores(text, text, uuid) from public;
grant execute on function public.shed_admin_scores(text, text, uuid) to anon, authenticated;
