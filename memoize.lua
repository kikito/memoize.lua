-----------------------------------------------------------------------------------------------------------------------
-- memoize.lua - v0.1 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- memoize lua functions easily
-- Based on http://stackoverflow.com/questions/129877/how-do-i-write-a-generic-memoize-function
-----------------------------------------------------------------------------------------------------------------------


local globalCache = {}

local function getFromCache(cache, args)
  local arg, i
  local node = cache
  for i=1, #args do
    arg = args[i]
    node = node.children[arg]
    if node == nil then return nil end
  end
  return node.value
end

local insertInCache(cache, args, result)
  local arg, i
  local node = cache
  for i=1, #args do
    arg = args[i]
    node.children = node.children or {}
    node.children[arg] = node.children[arg] or {}
  end
  node.value = result
end


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

