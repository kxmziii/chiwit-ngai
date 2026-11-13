// Service worker: keeps a copy of the app on the phone so it opens without a connection.
// The app itself is fetched from the network first, so a new version shows up as soon as the phone is online.
const CACHE = "chiwit-ngai-v3";
const SHELL = ["./", "./index.html", "./manifest.webmanifest", "./icons/icon-192.png", "./icons/icon-512.png", "./icons/icon-180.png"];

self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(key => key !== CACHE).map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

function keep(request, response) {
  const copy = response.clone();
  caches.open(CACHE).then(cache => cache.put(request, copy));
  return response;
}

self.addEventListener("fetch", event => {
  const request = event.request;
  if (request.method !== "GET") return;
  const url = new URL(request.url);

  if (url.origin === self.location.origin) {
    // Our own files: newest from the network, saved copy when offline
    event.respondWith(
      fetch(request)
        .then(response => keep(request, response))
        .catch(() => caches.match(request, { ignoreSearch: true }).then(hit => hit || caches.match("./index.html")))
    );
  } else if (/(^|\.)fonts\.(googleapis|gstatic)\.com$/.test(url.hostname)) {
    // Fonts never change: saved copy first
    event.respondWith(caches.match(request).then(hit => hit || fetch(request).then(response => keep(request, response))));
  }
});
