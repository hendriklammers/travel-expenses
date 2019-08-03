// This import is needed to get async/await working
import 'regenerator-runtime/runtime'

const VERSION = 'v1'
const CACHE_ID = `travel-expenses-${VERSION}`

self.addEventListener('activate', (event: ExtendableEvent) => {
  event.waitUntil(
    caches.keys().then(cacheNames =>
      Promise.all(cacheNames.map(cache => {
        // Remove all caches that are not the current one
        if (cache !== CACHE_ID) {
          return caches.delete(cache)
        }
      }) as Iterable<PromiseLike<boolean>>)
    )
  )
})

self.addEventListener('fetch', (event: FetchEvent) => {
  const { request } = event
  event.respondWith(caches.match(request).then(async (cachedRes: Response) => {
    try {
      // Try network first
      const res = await fetch(request)
      // Only GET request should be cached
      if (request.method.toLowerCase() === 'get') {
        const cache = await caches.open(CACHE_ID)
        cache.put(request, res.clone())
      }
      return res
    } catch {
      // When network fails, use cached version
      if (cachedRes) {
        return cachedRes
      }
    }
  }) as Promise<Response>)
})
