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

  before(function() counter = 0 end)

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

end)
