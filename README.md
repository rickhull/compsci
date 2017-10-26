[![Build Status](https://travis-ci.org/rickhull/compsci.svg?branch=master)](https://travis-ci.org/rickhull/compsci)

# Introduction

Provided are some toy implementations for some basic computer science problems.

## [`Tree`](/lib/compsci/tree.rb) data structures

* `Tree`       - enforces number of children per node
* `Tree::Node` - references parent and children nodes
* `BinaryTree` - subclass of `Tree`; child_slots == 2
* `CompleteBinaryTree` - efficient Array implementation

## [`Heap`](lib/compsci/heap.rb) data structure

Implemented with a `CompleteBinaryTree` for storage using simple arithmetic to
determine array indices for parent and children.  See the
[heap example](https://github.com/rickhull/compsci/blob/master/eamples/heap.rb)
which can be executed (among other examples) via `rake examples`.

Both minheaps and maxheaps are supported.  The primary operations are
`Heap#push` and `Heap#pop`.

## [`Fibonacci`](lib/compsci/fib.rb) functions

* `Fibonacci.classic(n)`         - naive, recursive
* `Fibonacci.cache_recursive(n)` - as above, caching already computed results
* `Fibonacci.cache_iterative(n)` - as above but iterative
* `Fibonacci.dynamic(n)`         - as above but without a cache structure

## [`Timer`](/lib/compsci/timer.rb) functions

* `Timer.now`          - uses `Process::CLOCK_MONOTONIC` if available
* `Timer.elapsed`      - provides the elapsed time to run a block
* `Timer.loop_average` - runs a block repeatedly and provides the mean elapsed
                         time
* `Timer.since`        - provides the elapsed time since a prior time

## [`Fit`](lib/compsci/fit.rb) functions

* asdf
