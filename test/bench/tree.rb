require 'compsci/tree'
require 'minitest/autorun'
require 'minitest/benchmark'

include CompSci

describe "BinaryTree#push Benchmark" do
  bench_range do
    # note, 5000 takes way too long and is definitely not constant time
    # TODO: BUG?
    # [10, 100, 1000, 2000, 5000]
    [10, 100, 1000, 2000]
  end

  bench_performance_constant "BinaryTree#push (constant)" do |n|
    tree = BinaryTree.new ChildNode.new 42
    n.times { tree.push rand 99 }
  end

  # this fails with r^2 around 0.91
  # bench_performance_linear "BinaryTree#push (linear)" do |n|
  #   tree = BinaryTree.new ChildNode.new 42
  #   n.times { tree.push rand 99 }
  # end
end
