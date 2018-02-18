package = "memoize"
version = "2.0.0-0"
source = {
  url = "https://github.com/kikito/memoize.lua/archive/v2.0.0.tar.gz",
  dir = "memoize.lua-2.0.0"
}
description = {
  summary = "Memoized functions in Lua",
  detailed = [[
    * Caches the results based on multiple parameters instead of just 1.
    * Doesn't rely on `tostring`; instead, it uses operator `==` on all the
      parameters (this is accomplished by structuring the cache in a
      tree structure, where each tree node corresponds to one
      parameter).
    * Works well with functions returning multiple values
    * Can memoize both functions and "callable tables" (tables with a `__call`
      metamethod)
  ]],
  homepage = "https://github.com/kikito/memoize.lua",
  license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      memoize = "memoize.lua"
   }
}
