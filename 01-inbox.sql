-- [01] Shed feedback + crash-report inboxes. Run in the PARTFINDER Supabase project
-- (ref ekcnpuwclkjnqnntlvot, same project as Breakin's tables), SQL editor, once.
--
-- >>> BEFORE RUNNING: in section 3, on the marked 'pass text :=' line, replace the placeholder with a NEW private
--     string (not Breakin's). Never commit the real value. Afterwards put the same value in
--     .claude/secrets/shed.env as SHED_ADMIN=... so work sessions can read the inbox.
--
-- Until this runs, the game still works: "Send feedback" says it could not send, crash
-- reports are dropped. Nothing else depends on these tables.

-- ---------- 1. feedback inbox (anyone can insert, nobody can read except via the admin RPC) ----------
create table if not exists public.shed_feedback (
  id uuid primary key default gen_random_uuid(),
  name text, message text not null,
  meta jsonb, created_at timestamptz not null default now(),
  constraint shed_fb_len check (char_length(message) between 1 and 2000 and char_length(coalesce(name,'')) <= 24)
);
alter table public.shed_feedback enable row level security;
drop policy if exists shed_fb_insert on public.shed_feedback;
create policy shed_fb_insert on public.shed_feedback
  for insert to anon, authenticated with check (char_length(message) between 1 and 2000);

-- ---------- 2. crash-report inbox ----------
create table if not exists public.shed_errors (
  id uuid primary key default gen_random_uuid(),
  msg text, stack text, ua text, url text,
  extra jsonb, created_at timestamptz not null default now(),
  constraint shed_err_len check (char_length(coalesce(msg,'')) <= 500 and char_length(coalesce(stack,'')) <= 4000
    and char_length(coalesce(ua,'')) <= 400 and char_length(coalesce(url,'')) <= 400)
);
alter table public.shed_errors enable row level security;
drop policy if exists shed_err_insert on public.shed_errors;
create policy shed_err_insert on public.shed_errors
  for insert to anon, authenticated with check (true);

-- ---------- 3. admin RPC: read and delete ----------
create or replace function public.shed_admin(action text, secret text, target uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare n int;
  -- >>> set your own passphrase on the next line. Do NOT commit the real value anywhere. <<<
  pass text := '__SET_YOUR_OWN_PASSPHRASE__';
begin
  -- the unedited placeholder never unlocks anything (built by concatenation so a find/replace can't touch it)
  if secret is null or pass = '__SET_' || 'YOUR_OWN_PASSPHRASE__' or secret <> pass then
    return jsonb_build_object('ok', false, 'error', 'bad passphrase');
  end if;

  if action = 'stats' then
    return jsonb_build_object('ok', true,
      'feedback', (select count(*) from shed_feedback),
      'errors',   (select count(*) from shed_errors));
  elsif action = 'feedback' then
    return coalesce((select jsonb_agg(row_to_json(t)) from (
      select id,name,message,meta,created_at from shed_feedback order by created_at desc limit 60) t), '[]'::jsonb);
  elsif action = 'errors' then
    return coalesce((select jsonb_agg(row_to_json(t)) from (
      select id,msg,stack,ua,url,extra,created_at from shed_errors order by created_at desc limit 60) t), '[]'::jsonb);
  elsif action = 'delete_feedback' then
    delete from shed_feedback where id = target;
    get diagnostics n = row_count;
    return jsonb_build_object('ok', true, 'deleted', n);
  elsif action = 'delete_error' then
    delete from shed_errors where id = target;
    get diagnostics n = row_count;
    return jsonb_build_object('ok', true, 'deleted', n);
  else
    return jsonb_build_object('ok', false, 'error', 'unknown action');
  end if;
end $$;

revoke all on function public.shed_admin(text, text, uuid) from public;
grant execute on function public.shed_admin(text, text, uuid) to anon, authenticated;
