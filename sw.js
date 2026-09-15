// Snaked offline shell - Breakin's sw.js with the names changed; the comments there explain every line.
// ponytail: network-first with an 8s timeout, so a hotfix lands on the next load and a dead connection still plays.
const C = 'snaked-v1';
const ASSETS = ['./', 'index.html', 'manifest.json', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(C)
    .then(c => c.addAll(ASSETS.map(u => new Request(u, {cache: 'reload'}))))
    .then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  // only our own caches: Breakin and CourtConnect share the github.io origin
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k.startsWith('snaked-') && k !== C).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  if (url.origin !== self.location.origin) return;   // feedback / crash reports go to Supabase - never touch them
  const key = url.origin + url.pathname;             // one copy per path, whatever the query string
  const ask = r => { try { return fetch(r.url, {cache: 'reload'}); } catch (_) { return fetch(r); } };
  const net = (e.request.mode === 'navigate' ? ask(e.request) : fetch(e.request)).then(res => {
    if (res.ok) { const copy = res.clone(); caches.open(C).then(c => c.put(key, copy)).catch(() => {}); }
    return res;
  });
  const cached = () => caches.match(key).then(r => r || caches.match('index.html'));
  e.respondWith(
    Promise.race([net.catch(() => null), new Promise(r => setTimeout(r, 8000))])
      .then(res => res || cached().then(r => r || net))
  );
});
