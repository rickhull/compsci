require 'compsci/heap'
require 'minitest/autorun'
require 'minitest/benchmark'

include CompSci

describe "Heap#push Benchmark" do
  before do
    @heap = Heap.new
  end

  bench_performance_constant "Heap#push (constant, 0.9999)", 0.9999 do |n|
    n.times { @heap.push rand 99999 }
  end
end
