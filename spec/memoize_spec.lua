local memoize = require 'memoize' 

context( 'memoize', function()

  local counter = 0

  local function count(...)
    counter = counter + 1
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
    memoized_count()
    memoized_count()
    assert_equal(counter, 1)
  end)

  test("should work with one parameter", function()
    memoized_count('foo')
    memoized_count('foo')
    memoized_count('foo')
    assert_equal(counter, 1)
  end)

  test("should work with two parameters", function()
    memoized_count('foo', 'bar')
    memoized_count('foo', 'baz')
    assert_equal(counter, 2)
    memoized_count('foo', 'bar')
    memoized_count('foo', 'bar')
    assert_equal(counter, 2)
  end)

  test("should work with tables & functions", function()
    local t = {}
    memoized_count(print, t)
    memoized_count(print, t)
    assert_equal(counter, 1)
    local another_t = {}
    memoized_count(print, another_t)
    assert_equal(counter, 2)
  end)

  test("should return multiple values when needed", function()
    local x,y = memoized_switch(100, 200)
    assert_equal(count, 1)
    assert_equal(x, 200)
    assert_equal(y, 100)
    x,y = memoized_switch(100, 200)
    assert_equal(count, 1)
    assert_equal(x, 200)
    assert_equal(y, 100)
  end)

end)
