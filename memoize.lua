-----------------------------------------------------------------------------------------------------------------------
-- memoize.lua - v1.0 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- memoize lua functions easily
-- Based on http://stackoverflow.com/questions/129877/how-do-i-write-a-generic-memoize-function
-----------------------------------------------------------------------------------------------------------------------

--[[ usage:

local memoize = require 'memoize' -- or memoize.lua, depending on your env.

function slowFunc(param1, param2, param3)
  -- do something expensive, like calculating a value or reading a file
end

local memoizedSlowFunc = memoize(slowFunc)

-- First execution takes some time, but the system caches the result
memoizedSlowFunc('a','b') -- first time is slow

-- Second execution is fast, since the system uses the cache
memoizedSlowFunc('a','b') -- second time is fast
memoizedSlowFunc('a','b') -- from now on, it is fast

-- This happens with every new combination of params
memoizedSlowFunc('c','d') -- slow
memoizedSlowFunc('e','f') -- slow
memoizedSlowFunc('c','d') -- fast
]]


-- private stuff

local globalCache = {}

local function getFromCache(cache, args)
  local arg, i
  local node = cache
  for i=1, #args do
    arg = args[i]
    node.children = node.children or {}
    node = node.children[arg]
    if node == nil then return nil end
  end
  return node.value
end

local function insertInCache(cache, args, result)
  local arg, i
  local node = cache
  for i=1, #args do
    arg = args[i]
    node.children = node.children or {}
    node.children[arg] = node.children[arg] or {}
    node = node.children[arg]
  end
  node.value = result
end


-- public function

local function memoize(f)
  globalCache[f] = {}
  return function (...)
    local result = getFromCache( globalCache[f], {...} )
      
    if result == nil then
      result = f(...)
      insertInCache(globalCache[f], {...}, result)
      return result
    end
  end
end

return memoize

