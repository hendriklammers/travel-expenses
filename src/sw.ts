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
          console.info('Removing outdated cache:', cache)
          return caches.delete(cache)
        }
      }) as Iterable<PromiseLike<boolean>>)
    )
  )
})

self.addEventListener('fetch', (event: FetchEvent) => {
  const { request } = event
  event.respondWith(caches.match(request).then(async (cachedRes: Response) => {
    const url = request.url
    try {
      // Try network first
      const res = await fetch(request)
      console.log(`Fresh response for: ${url}`)
      // Only GET request should be cached
      if (request.method.toLowerCase() === 'get') {
        const cache = await caches.open(CACHE_ID)
        cache.put(request, res.clone())
      }
      return res
    } catch (err) {
      console.warn(err)
      // When network fails, use cached version
      if (cachedRes) {
        console.log(`Cached response for: ${url}`)
        return cachedRes
      }
    }
  }) as Promise<Response>)
})
