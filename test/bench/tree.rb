require 'compsci/tree'
require 'benchmark/ips'

include CompSci

Benchmark.ips do |b|
  b.config time: 3, warmup: 0.5

  b.report("99x BinaryTree(ChildNode)#push") do
    tree = BinaryTree.new(ChildNode, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x BinaryTree(Node)#push") do
    tree = BinaryTree.new(Node, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(ChildNode)#push") do
    tree = TernaryTree.new(ChildNode, 42)
    99.times { tree.push rand 99 }
  end

  b.report("99x TernaryTree(Node)#push") do
    tree = TernaryTree.new(Node, 42)
    99.times { tree.push rand 99 }
  end

  b.compare!
end
