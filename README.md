[![Build Status](https://travis-ci.org/rickhull/compsci.svg?branch=master)](https://travis-ci.org/rickhull/compsci)

# Introduction

Provided are some toy implementations for some basic computer science problems.

* Heap (min- or max-)
* Fibonacci function
  - `Fibonacci.classic(n)` - naive, recursive
  - `Fibonacci.cache_recursive(n)` - as above, caching already computed results
  - `Fibonacci.cache_iterative(n)` - as above but iterative
  - `Fibonacci.dynamic(n)` - as above but without a cache structure

## Heap

Implemented with an array for storage and simple arithmetic to determine the
array index for parent and children.  See the
[heap demo](https://github.com/rickhull/compsci/blob/master/test/demo/heap.rb)
which can be executed (among other demos) via `rake demo`.

## Fibonacci

Simpler and easier to show than tell:

```ruby
require 'compsci'

module CompSci::Fibonacci
  def self.classic(n)
    n < 2 ? n : classic(n-1) + classic(n-2)
  end

  def self.cache_recursive(n, cache = {})
    return n if n < 2
    cache[n] ||= cache_recursive(n-1, cache) + cache_recursive(n-2, cache)
  end

  def self.cache_iterative(n)
    cache = [0, 1]
    2.upto(n) { |i| cache[i] = cache[i-1] + cache[i-2] }
    cache[n]
  end

  def self.dynamic(n)
    a, b = 0, 1
    (n-1).times { a, b = b, a+b }
    b
  end
end
```

## Timer

As with Fibonacci:

```ruby
require 'compsci'

module CompSci::Timer
  def self.loop_average(count: 999, seconds: 1, &work)
    i = 0
    t = Time.now
    loop {
      yield
      i += 1
      break if i >= count
      break if Time.now - t > seconds
    }
    (Time.now - t) / i.to_f
  end
end
```
