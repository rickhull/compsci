require 'compsci/node'
require 'compsci/tree'
require 'benchmark/ips'

include CompSci

Benchmark.ips do |b|
  b.config time: 3, warmup: 0.5

  b.report("99x BinaryTree(ChildFlexNode)#push") do
    tree = PushTree.new(ChildFlexNode, 42, child_slots: 2)
    99.times { tree.push rand 99 }
  end

  b.report("99x BinaryTree(FlexNode)#push") do
    tree = PushTree.new(FlexNode, 42, child_slots: 2)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(ChildFlexNode)#push") do
    tree = PushTree.new(ChildFlexNode, 42, child_slots: 3)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(FlexNode)#push") do
    tree = PushTree.new(FlexNode, 42, child_slots: 3)
    99.times { tree.push rand 99 }
  end

  b.compare!
end
