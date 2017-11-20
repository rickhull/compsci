require 'compsci/flex_node'
require 'benchmark/ips'

include CompSci

Benchmark.ips do |b|
  b.config time: 3, warmup: 0.5

  b.report("99x Binary ChildFlexNode#push") do
    @root = ChildFlexNode.new 42
    99.times { @root.push rand(99), 2 }
  end

  b.report("99x Binary FlexNode#push") do
    @root = FlexNode.new 42
    99.times { @root.push rand(99), 2 }
  end

  b.report("99x Ternary ChildFlexNode#push") do
    @root = ChildFlexNode.new 42
    99.times { @root.push rand(99), 3 }
  end

  b.report("99x Ternary FlexNode#push") do
    @root = FlexNode.new 42
    99.times { @root.push rand(99), 3 }
  end

  b.compare!
end
