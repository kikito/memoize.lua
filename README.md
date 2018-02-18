memoize.lua
===========

[![Build Status](https://travis-ci.org/kikito/memoize.lua.svg?branch=master)](https://travis-ci.org/kikito/memoize.lua)

This is a pure-Lua memoization function that builds upon what was shown
in [Programming In Lua's memoization implementation](http://www.lua.org/pil/17.1.html) function.

Main characteristics:

-   Caches the results based on multiple parameters instead of just 1.
-   Doesn't rely on `tostring`; instead, it uses operator `==` on all the
    parameters (this is accomplished by structuring the cache in a
    tree structure, where each tree node corresponds to one
    parameter).
-   Works well with functions returning multiple values
-   Can memoize both functions and "callable tables" (tables with a `__call`
    metamethod)

Partially inspired by [this StackOverflow question](http://stackoverflow.com/questions/129877/how-do-i-write-a-generic-memoize-function)

Synopsis
========

``` lua
local memoize = require 'memoize'

local memoized_f = memoize(f, <cache>)
```

Params:

-  `f` is the object we want to memoize. It can be either a function or a callable
    table. If `f` is something other than that, `memoize(f)` will throw an error.
-  `cache` (optional) is the object which will be used for caching. If not provided
    memoize will use an internal table instead (see below). `memoize` won't check
    that the provided `cache` is a table, but it will attempt to insert a table
    called `children` inside of it.

Examples of use
===============

`memoize.lua` can be used to avoid stack overflow & slow performance on
recursive functions, in exchange for memory. In some cases it might be
necessary to "seed the function" before using it.

``` lua
local memoize = require 'memoize'

local function tri(x)
  if x == 0 then return 0 end
  return x+tri(x-1)
end

print(tri(40000)) -- stack overflow: too much recursion

local memoized_tri = memoize(tri) -- memoized_tri "remembers" previous results

for i=0, 40000 do memoized_tri(i) end -- seed cache

print(memoized_tri(40000)) -- 800020000, instantaneous result
```

Another use for `memoize.lua` is on resource-loading functions. Let's
say you have an image-loading function called `load_image`. You'd like
to use the image loaded by that function on two different places in your
code, but you are unsure of which of those places will call `load_image`
first; and you don't want to load two images.

``` lua
function load_image(path)
  ...
  return image
end

function f()
  local image = load_image(path)
  ...
end

function g()
  local image = load_image(path)
  ...
end
```

You can just memoize `load_image`; the image will be loaded the first
time `load_image` is invoked, and will be recovered from the cache on
subsequent calls.

``` lua
local memoize = require 'memoize'

local function load_image(path)
  ...
  return image
end

local memoized_load_image = memoize(load_image)

function f()
  local image = memoized_load_image(path)
  ...
end

function g()
  local image = memoized_load_image(path)
  ...
end
```

Gotcha / Warning
==================

**`nil` return values are considered cache-misses and thus are never
cached**; If you need to cache a function that doesn't return
anything, make it return a dummy not-nil value (`false`, `''`, `0` or
any other non-nil value will work just fine).


Cache utilization & structure
=============================

Each memoized function has an internal cache. If you want to recuperate the memory
consumed by a memoized function's cache, the simplest way of doing so is removing
all references to the memoized function. Once the collector runs, you should get the
memory back.

``` lua
local mf = memoize(f)
mf(1)
mf(2)
mf(3)
...
mf = nil -- memory for mf will be liberated
...
local mf2 = memoize(f) -- you can memoize the same function again if you need

```

`memoize.lua` stores the information in a tree-like structure, where the nodes
are parameters and the leafs are results. For example, take the `sum` function,
which operates on a variable list of arguments:

``` lua
local sum = function(...)
  local result = 0
  local params = { ... }
  for i = 1, #params do
    result = result + params[i]
  end
  return result
end
```

If we memoize it and seed the memoized function like so:

``` lua
local memoized_sum = memoize(sum)

print(memoized_sum())     -- 0
print(memoized_sum(1))    -- 1
print(memoized_sum(1, 2)) -- 3
print(memoized_sum(3, 1)) -- 4
```

The internal cache would have the following structure:

```
{
  results  = { 0 },
  children = {
    [1] = {
      results = { 1 },
      children = {
        [2] = {
          results = { 3 },
        }
      }
    }
    [3] = {
      children = {
        [1] = {
          result = { 4 },
        }
      }
    }
  }
}

```

If you use the default cache, removing all the references to the memoized
function is the only way to liberate memory. If you need more control
on the cache, you can use `memoize`'s second parameter to provide a cache
which you control:

``` lua
local my_cache = {}

local mf = memoize(f, my_cache)

mf(1)
mf(1, 2)
mf(4)

my_cache.children[1] = nil -- partially expunge the cache
```

In the example above, the memory dedicated to results `mf(1)` and `mf(1,2)` has been
erased, but the memory storing `mf(4)` is still in use.

The second parameter also allows sharing a single cache amongst two memoized functions.


## Changelog

See CHANGELOG.md for details

## License

MIT
