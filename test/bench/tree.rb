require 'compsci/node'
require 'compsci/tree'
require 'benchmark/ips'

include CompSci

Benchmark.ips do |b|
  b.config time: 3, warmup: 0.5

  b.report("99x BinaryTree(ChildNode)#push") do
    tree = BinaryTree.new(ChildFlexNode, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x BinaryTree(FlexNode)#push") do
    tree = BinaryTree.new(FlexNode, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(ChildFlexNode)#push") do
    tree = TernaryTree.new(ChildFlexNode, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(FlexNode)#push") do
    tree = TernaryTree.new(FlexNode, 42)
    99.times { tree.push rand 99 }
  end

  b.compare!
end
