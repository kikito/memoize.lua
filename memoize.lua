-----------------------------------------------------------------------------------------------------------------------
-- memoize.lua - v1.0 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- memoize lua functions easily
-- Inspired by http://stackoverflow.com/questions/129877/how-do-i-write-a-generic-memoize-function
-----------------------------------------------------------------------------------------------------------------------

--[[ usage:

local memoize = require 'memoize' -- or memoize.lua, depending on your env.

function slowFunc(param1, param2)
  -- do something expensive, like calculating a value or reading a file
  return somethingSlow
end

local memoizedSlowFunc = memoize(slowFunc)

-- First execution takes some time, but the system caches the result
x = memoizedSlowFunc('a','b') -- first time is slow

-- Second execution is fast, since the system uses the cache
x = memoizedSlowFunc('a','b') -- second time is fast
x = memoizedSlowFunc('a','b') -- from now on, it is fast

-- This happens with every new combination of params
y = memoizedSlowFunc('c','d') -- slow
z = memoizedSlowFunc('e','f') -- slow
y = memoizedSlowFunc('c','d') -- fast
]]


-- private stuff

local globalCache = {}

local function isCallable(f)
  local tf = type(f)
  if tf == 'function' then return true end
  if tf == 'table' then
    local mt = getmetatable(f)
    if type(mt)=='table' then
      return type(mt.__call) == "function"
    end
  end
  return false
end

local function getFromCache(cache, args)
  local node = cache
  for i=1, #args do
    if not node.children then return {} end
    node = node.children[args[i]]
    if not node then return {} end
  end
  return node.results
end

local function insertInCache(cache, args, results)
  local arg, i
  local node = cache
  for i=1, #args do
    arg = args[i]
    node.children = node.children or {}
    node.children[arg] = node.children[arg] or {}
    node = node.children[arg]
  end
  node.results = results
end


-- public function

local function memoize(f)
  assert(isCallable(f), "Only functions and callable tables are admitted on memoize. Received " .. tostring(f))
  globalCache[f] = { results = {} }
  return function (...)
    local results = getFromCache( globalCache[f], {...} )
      
    if #results == 0 then
      results = { f(...) }
      insertInCache(globalCache[f], {...}, results)
    end
    
    return unpack(results)
  end
end

return memoize

