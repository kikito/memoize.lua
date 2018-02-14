# memoize.lua changelog

## v2.0

* Changed the cache model in order to solve an issue regarding memory consumption (#5)
* Made callable tables a bit more resilient: cached values are still returned after a callable table loses its `_call` metamethod.
* Added the second parameter `cache`
