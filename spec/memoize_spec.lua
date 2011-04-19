local memoize = require 'memoize' 

context( 'memoize', function()

  local counter = 0

  local function count(...)
    counter = counter + 1
    return counter
  end

  local memoized_count = memoize(count)

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

end)
