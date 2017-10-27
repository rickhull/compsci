require 'compsci/heap'
require 'minitest/autorun'

include CompSci

describe Heap do
  before do
    @maxheap = Heap.new
    @minheap = Heap.new(minheap: true)
    @inserts = (1..10).to_a
    @inserts.each { |i|
      @maxheap.push i
      @minheap.push i
    }
  end

  it "must satisfy the heap property" do
    @maxheap.heap?.must_equal true
    @minheap.heap?.must_equal true
    @minheap.array.must_equal @inserts
    @maxheap.array.wont_equal @inserts
    @maxheap.array.wont_equal @inserts.reverse
  end

  it "must recognize heap violations" do
    @minheap.array.push 0
    @minheap.heap?.must_equal false
    @minheap.sift_up @minheap.last_idx
    @minheap.heap?.must_equal true

    @minheap.array.unshift 10
    @minheap.heap?.must_equal false
    @minheap.sift_down 0
    @minheap.heap?.must_equal true

    @maxheap.array.push 10
    @maxheap.heap?.must_equal false
    @maxheap.sift_up @maxheap.last_idx
    @maxheap.heap?.must_equal true

    @maxheap.array.unshift 0
    @maxheap.heap?.must_equal false
    @maxheap.sift_down 0
    @maxheap.heap?.must_equal true
  end
end
