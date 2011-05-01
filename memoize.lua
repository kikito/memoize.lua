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

local function getCallMetamethod(f)
  if type(f) ~= 'table' then return nil end
  local mt = getmetatable(f)
  return type(mt)=='table' and mt.__call
end

local function resetCache(f, call)
  globalCache[f] = { results = {}, children = {}, call = call or getCallMetamethod(f) }
end

local function getCacheNode(cache, args)
  local node = cache
  for i=1, #args do
    node = node.children[args[i]]
    if not node then return nil end
  end
  return node
end

local function getOrBuildCacheNode(cache, args)
  local arg
  local node = cache
  for i=1, #args do
    arg = args[i]
    node.children[arg] = node.children[arg] or { children = {} }
    node = node.children[arg]
  end
  return node
end

local function getFromCache(cache, args)
  local node = getCacheNode(cache, args)
  return node and node.results or {}
end

local function insertInCache(cache, args, results)
  local node = getOrBuildCacheNode(cache, args)
  node.results = results
end

local function resetCacheIfMetamethodChanged(t)
  local call = getCallMetamethod(t)
  assert(type(call) == "function", "The __call metamethod must be a function") 
  if globalCache[t].call ~= call then
    resetCache(t, call)
  end
end

local function buildMemoizedFunction(f)
  local tf = type(f)
  return function (...)
    if tf == "table" then resetCacheIfMetamethodChanged(f) end

    local results = getFromCache( globalCache[f], {...} )

    if #results == 0 then
      results = { f(...) }
      insertInCache(globalCache[f], {...}, results)
    end
    
    return unpack(results)
  end
end

local function isCallable(f)
  local tf = type(f)
  if tf == 'function' then return true end
  if tf == 'table' then
    return type(getCallMetamethod(f))=="function"
  end
  return false
end

local function assertCallable(f)
  assert(isCallable(f), "Only functions and callable tables are admitted on memoize. Received " .. tostring(f))
end

-- public function

local function memoize(f)
  assertCallable(f)
  resetCache(f)
  return buildMemoizedFunction(f)
end

return memoize

