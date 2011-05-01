local memoize = require 'memoize'

context( 'memoize', function()

  local counter = 0

  local function count(...)
    counter = counter + 1
    return counter
  end

  local memoized_count = memoize(count)

  local function switch(x,y)
    counter = counter + 1
    return y,x
  end

  local memoized_switch = memoize(switch)

  local countable = setmetatable({}, {__call = count})
  local memoized_countable = memoize(countable)

  local function count2(...)
    counter = counter + 1
    return counter
  end

  before(function()
    counter = 0
  end)

  test("should accept ony non-callable parameters, and error otherwise", function()
    assert_error(function() memoize() end)
    assert_error(function() memoize('foo') end)
    assert_error(function() memoize(1) end)
    assert_error(function() memoize({}) end)
    assert_not_error(function() memoize(print) end)
    assert_not_error(function() memoize(countable) end)
  end)

  test("should work with 0 parameters", function()
    memoized_count()
    assert_equal(memoized_count(), 1)
    assert_equal(counter, 1)
  end)

  test("should work with one parameter", function()
    memoized_count('foo')
    assert_equal(memoized_count('foo'), 1)
    assert_equal(memoized_count('bar'), 2)
    assert_equal(memoized_count('foo'), 1)
    assert_equal(memoized_count('bar'), 2)
    assert_equal(counter, 2)
  end)

  test("should work with two parameters", function()
    memoized_count('foo', 'bar')
    assert_equal(memoized_count('foo', 'bar'), 1)
    assert_equal(memoized_count('foo', 'baz'), 2)
    assert_equal(memoized_count('foo', 'bar'), 1)
    assert_equal(memoized_count('foo', 'baz'), 2)
    assert_equal(counter, 2)
  end)

  test("should work with tables & functions", function()
    local t1 = {}
    local t2 = {}
    assert_equal(memoized_count(print, t1), 1)
    assert_equal(memoized_count(print, t2), 2)
    assert_equal(memoized_count(print, t1), 1)
    assert_equal(memoized_count(print, t2), 2)
    assert_equal(counter, 2)
  end)

  test("should return multiple values when needed", function()
    local x,y = memoized_switch(100, 200)
    assert_equal(x, 200)
    assert_equal(y, 100)
    assert_equal(counter, 1)
    x,y = memoized_switch(400, 500)
    assert_equal(x, 500)
    assert_equal(y, 400)
    assert_equal(counter, 2)
    x,y = memoized_switch(100, 200)
    assert_equal(x, 200)
    assert_equal(y, 100)
    assert_equal(counter, 2)
    x,y = memoized_switch(400, 500)
    assert_equal(x, 500)
    assert_equal(y, 400)
    assert_equal(counter, 2)
  end)

  test("should clean cache when called twice", function()
    memoized_count('reset')
    assert_equal(memoized_count('reset'), 1)
    memoize(count)
    assert_equal(memoized_count('reset'), 2)
  end)

  context( 'callable tables', function()
    
    test("Unchanged callable tables should work just like functions", function()
      memoized_countable()
      assert_equal(memoized_countable(), 1)
      assert_equal(counter, 1)
      memoized_countable('foo')
      assert_equal(memoized_countable('foo'), 2)
      assert_equal(counter, 2)
    end)

    test("When callable table's __call metamethod is changed, the cache is reset", function()
      memoized_countable('bar')
      assert_equal(memoized_countable('bar'), 1)
      local mt = getmetatable(countable)
      mt.__call = count2
      memoized_countable('bar')
      assert_equal(memoized_countable('bar'), 2)
      assert_equal(memoized_countable('bar'), 2)
    end)

    test("An error is thrown if a memoized callable table loses its __call", function()
      local mt = getmetatable(countable)
      mt.__call = nil
      assert_error(function() memoized_countable() end)
    end)
  end)

end)
