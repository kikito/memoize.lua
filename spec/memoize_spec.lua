local memoize = require 'memoize'

describe('memoize', function()
  local counter
  before_each(function()
    counter = 0
  end)

  it("accepts ony non-callable parameters, and error otherwise", function()
    assert.error(function() memoize() end)
    assert.error(function() memoize('foo') end)
    assert.error(function() memoize(1) end)
    assert.error(function() memoize({}) end)
    assert.not_error(function() memoize(print) end)
    local callable1 = setmetatable({}, { __call = print })
    assert.not_error(function() memoize(callable1) end)
    local callable2 = setmetatable({}, { __call = callable1 })
    assert.not_error(function() memoize(callable2) end)
  end)

  describe("a memoized function", function()
    local count = function()
      counter = counter + 1
      return counter
    end

    local memoized_count

    before_each(function()
      memoized_count = memoize(count)
    end)

    it("works with 0 parameters", function()
      memoized_count()
      assert.equal(1, memoized_count())
      assert.equal(1, counter)
    end)

    it("works with one parameter", function()
      memoized_count('foo')
      assert.equal(1, memoized_count('foo'))
      assert.equal(2, memoized_count('bar'))
      assert.equal(1, memoized_count('foo'))
      assert.equal(2, memoized_count('bar'))
      assert.equal(counter, 2)
    end)

    it("works with two parameters", function()
      memoized_count('foo', 'bar')
      assert.equal(1, memoized_count('foo', 'bar'))
      assert.equal(2, memoized_count('foo', 'baz'))
      assert.equal(1, memoized_count('foo', 'bar'))
      assert.equal(2, memoized_count('foo', 'baz'))
      assert.equal(counter, 2)
    end)

    it("works with tables & functions", function()
      local t1 = {}
      local t2 = {}
      assert.equal(1, memoized_count(print, t1))
      assert.equal(2, memoized_count(print, t2))
      assert.equal(1, memoized_count(print, t1))
      assert.equal(2, memoized_count(print, t2))
      assert.equal(counter, 2)
    end)

    it("returns multiple values when needed", function()
      local switch = memoize(function(x,y)
        counter = counter + 1
        return y,x
      end)
      local memoized_switch = memoize(switch)
      local x,y = memoized_switch(100, 200)
      assert.equal(200, x)
      assert.equal(100, y)
      assert.equal(counter, 1)
      x,y = memoized_switch(400, 500)
      assert.equal(500, x)
      assert.equal(400, y)
      assert.equal(counter, 2)
      x,y = memoized_switch(100, 200)
      assert.equal(200, x)
      assert.equal(100, y)
      assert.equal(counter, 2)
      x,y = memoized_switch(400, 500)
      assert.equal(500, x)
      assert.equal(400, y)
      assert.equal(counter, 2)
    end)
  end)

  describe('a callable table', function()
    local countable, memoized_countable

    before_each(function()
      local count = function()
        counter = counter + 1
        return counter
      end
      countable = setmetatable({}, { __call = count })
      memoized_countable = memoize(countable)
    end)

    it("works just like a function", function()
      memoized_countable()
      assert.equal(1, memoized_countable())
      assert.equal(1, counter)
      memoized_countable('foo')
      assert.equal(2, memoized_countable('foo'))
      assert.equal(2, counter)
    end)

    it("returns cached values even when the memoized table is not callable any more", function()
      local mt = getmetatable(countable)
      memoized_countable('a param')
      mt.__call = nil
      assert.no_error(function() memoized_countable('a param') end)
    end)

    it("throws an error when the memoized table is not callable any more and the cache misses", function()
      local mt = getmetatable(countable)
      mt.__call = nil
      assert.error(function() memoized_countable('a new param') end)
    end)
  end)


  describe('the cache param', function()
    local len = function(...)
      counter = counter + 1
      return #{...}
    end

    it("allows partially emptying a cache", function()
      local cache = {}
      local mlen = memoize(len, cache)
      assert.equal(1, mlen('freddie'))
      assert.equal(1, counter)
      assert.equal(1, mlen('freddie'))
      assert.equal(1, counter)

      assert.equal(3, mlen('freddie', 'tina', 'bowie'))
      assert.equal(2, counter)
      assert.equal(3, mlen('freddie', 'tina', 'bowie'))
      assert.equal(2, counter)

      assert.equal(1, mlen('michael'))
      assert.equal(3, counter)
      assert.equal(1, mlen('michael'))
      assert.equal(3, counter)

      cache.children['freddie'] = nil

      assert.equal(1, mlen('freddie'))
      assert.equal(4, counter)
      assert.equal(1, mlen('freddie'))
      assert.equal(4, counter)

      assert.equal(3, mlen('freddie', 'tina', 'bowie'))
      assert.equal(5, counter)
      assert.equal(3, mlen('freddie', 'tina', 'bowie'))
      assert.equal(5, counter)

      assert.equal(1, mlen('michael'))
      assert.equal(5, counter)
    end)

    it("allows sharing a cache amongst two memoized functions", function()
      local len2 = function(...)
        counter = counter + 10
        return #{...}
      end

      local cache = {}
      local mlen  = memoize(len, cache)
      local mlen2 = memoize(len2, cache)

      assert.equal(1, mlen('a'))
      assert.equal(1, counter)

      assert.equal(1, mlen2('a'))
      assert.equal(1, counter)

      assert.equal(4, mlen2('a', 'b', 'c', 'd'))
      assert.equal(11, counter)

      assert.equal(4, mlen('a', 'b', 'c', 'd'))
      assert.equal(11, counter)
    end)
  end)

end)
