require 'compsci/tree'
require 'minitest/autorun'
require 'minitest/benchmark'

include CompSci

describe "Tree#push Benchmark" do
  bench_range do
    # note, 5000 takes way too long and is definitely not constant time
    # TODO: BUG?
    # [10, 100, 1000, 2000, 5000]
    [10, 100, 1000, 2000]
  end

  bench_performance_constant "Tree#push (constant)" do |n|
    tree = Tree.new Tree::Node.new 42
    n.times { tree.push rand 99 }
  end
end
