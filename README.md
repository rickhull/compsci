[![Build Status](https://travis-ci.org/rickhull/compsci.svg?branch=master)](https://travis-ci.org/rickhull/compsci)

# CompSci

Provided are some toy implementations for some basic computer science problems.

## [`Node`](lib/compsci/node.rb) data structure

* `Node`
  - `@value`
  - `@children`
  - `#set_child(idx, node)`
* `KeyNode` inherits from `Node`; adds a key
  - `@key`
* `FlexNode` inherits from `Node`; accumulates children
  - `#add_child(node)`
  - `#new_child(value)`
  - `#add_parent(node)`
* `ChildNode` inherits from `Node`; adds a parent
  - `@parent`
  - `#gen`
  - `#siblings`
* `ChildFlexNode` inherits from `ChildNode`; accumulates children
  - `#add_child(node)`
  - `#new_child(value)`
  - `#add_parent(node)`

## [`Tree`](lib/compsci/tree.rb) data structures

* `Tree`
  - `@root`
  - `#df_search`
  - `#bf_search`
* `NaryTree`
  - `@child_slots` (number of children per node)
  - `#open_parent` O(n) to find a node with open child slots
  - `#push` append `#open_parent.children`
  - `#display` if initialized with `ChildNode`
* `BinaryTree`
  - `NaryTree.new(child_slots: 2)`
  - `#display` for `Node` and `ChildNode`
* `TernaryTree`
  - `NaryTree.new(child_slots: 3)`
* `QuaternaryTree`
  - `NaryTree.new(child_slots: 4)`

## [`CompleteNaryTree`](lib/compsci/complete_tree.rb) data structure

Efficient Array implementation of a complete tree.

* `CompleteNaryTree`
  - `CompleteNaryTree.parent_idx`
  - `CompleteNaryTree.children_idx`
  - `CompleteNaryTree.gen`
  - `@array`
  - `@child_slots`
  - `#push`
  - `#pop`
  - `#size`
  - `#last_idx`
  - `#display` (alias `#to_s`)
* `CompleteBinaryTree`
  - `CompleteNaryTree.new(child_slots: 2)`
* `CompleteTernaryTree`
  - `CompleteNaryTree.new(child_slots: 3)`
* `CompleteQuaternaryTree`
  - `CompleteNaryTree.new(child_slots: 4)`

## [`BinarySearchTree`](lib/compsci/binary_search_tree.rb) data structure

Based on `BinaryTree` of `KeyNode`.  The position of a node depends on its
key and how the key relates to the existing node keys.

* `BinarySearchTree`
  - `BinarySearchTree.new_node` helper method to create a node
  - `BinarySearchTree.new_with_kv` helper method to create a tree
  - `#search_recursive`
  - `#search_iterative`
  - `#insert_recursive`

## [`Heap`](lib/compsci/heap.rb) data structure

`CompleteNaryTree` implementation.  Both minheaps and maxheaps are supported.
Any number of children may be provided via `child_slots`.  The primary
operations are `Heap#push` and `Heap#pop`. See the
[heap](examples/heap.rb) [examples](examples/heap_push.rb)
which can be executed (among other examples) via `rake examples`.

My basic Vagrant VM gets over [500k pushes per second, constant up past 1M
pushes](reports/examples#L484).

## [`Fibonacci`](lib/compsci/fibonacci.rb) functions

* `Fibonacci.classic(n)`         - naive, recursive
* `Fibonacci.cache_recursive(n)` - as above, caching already computed results
* `Fibonacci.cache_iterative(n)` - as above but iterative
* `Fibonacci.dynamic(n)`         - as above but without a cache structure
* `Fibonacci.matrix(n)`          - matrix is magic; beats dynamic around n=500

## [`Timer`](/lib/compsci/timer.rb) functions

* `Timer.now`      - uses `Process::CLOCK_MONOTONIC` if available
* `Timer.since`    - provides the elapsed time since a prior time
* `Timer.elapsed`  - provides the elapsed time to run a block
* `Timer.loop_avg` - loops a block; returns final value and mean elapsed time

```ruby
require 'compsci/timer'

include CompSci

overall_start = Timer.now

start = Timer.now
print "running sleep 0.01 (50x): "
_answer, each_et = Timer.loop_avg(count: 50) {
  print '.'
  sleep 0.01
}
puts
puts "each: %0.3f" % each_et
puts "elapsed: %0.3f" % Timer.since(start)
puts "cumulative: %0.3f" % Timer.since(overall_start)
puts


start = Timer.now
print "running sleep 0.02 (0.3 s): "
_answer, each_et = Timer.loop_avg(seconds: 0.3) {
  print '.'
  sleep 0.02
}
puts
puts "each: %0.3f" % each_et
puts "elapsed: %0.3f" % Timer.since(start)
puts "cumulative: %0.3f" % Timer.since(overall_start)
puts
```

```
running sleep 0.01 (50x): ..................................................
each: 0.010
elapsed: 0.524
cumulative: 0.524

running sleep 0.02 (0.3 s): ...............
each: 0.020
elapsed: 0.304
cumulative: 0.828
```

## [`Fit`](lib/compsci/fit.rb) functions

* `Fit.sigma` - sums the result of a block applied to array values
* `Fit.error` - returns a generic r^2 value, the coefficient of determination
* `Fit.constant` - fits `y = a + 0x`; returns the mean and variance
* `Fit.logarithmic` - fits `y = a + b*ln(x)`; returns a, b, r^2
* `Fit.linear` - fits `y = a + bx`; returns a, b, r^2
* `Fit.exponential` fits `y = ae^(bx)`; returns a, b, r^2
* `Fit.power` fits `y = ax^b`; returns a, b, r^2

## [`Names`](lib/compsci/names.rb) functions

* `Names.assign`
* `Names::Greek.upper`
* `Names::Greek.lower`
* `Names::Greek.symbol`

## [`Simplex`](lib/compsci/simplex.rb) class

The Simplex algorithm is a technique for Linear Programming.  Typically the
problem is to maximize some linear expression of variables given some
constraints on those variables given in terms of linear inequalities.

### [`Simplex::Parse`](lib/compsci/simplex/parse.rb) functions

* `Parse.tokenize` - convert a string to an array of tokens
* `Parse.term`     - parse certain tokens into [coefficient, varname]
* `Parse.expression` - parse a string representing a sum of terms
* `Parse.inequality` - parse a string like "#{expression} <= #{const}"

With `Simplex::Parse`, one can obtain solutions via:

* `Simplex.maximize` - takes an expression to maximize followed by a variable
                       number of constraints / inequalities; returns a solution
* `Simplex.problem` - a more general form of `Simplex.maximize`; returns a
                      Simplex object

```ruby
require 'compsci/simplex/parse'

include CompSci

Simplex.maximize('x + y',
                 '2x + y <= 4',
		 'x + 2y <= 3')

# => [1.6666666666666667, 0.6666666666666666]



s = Simplex.problem(maximize: 'x + y',
                    constraints: ['2x + y <= 4',
                                  'x + 2y <= 3'])

# => #<CompSci::Simplex:0x0055b2deadbeef
#      @max_pivots=10000,
#      @num_non_slack_vars=2,
#      @num_constraints=2,
#      @num_vars=4,
#      @c=[-1.0, -1.0, 0, 0],
#      @a=[[2.0, 1.0, 1, 0], [1.0, 2.0, 0, 1]],
#      @b=[4.0, 3.0],
#      @basic_vars=[2, 3],
#      @x=[0, 0, 4.0, 3.0]>

s.solution

# => [1.6666666666666667, 0.6666666666666666]
```
