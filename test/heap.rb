require 'compsci/heap'
require 'minitest/autorun'

include CompSci

describe Heap do
  describe "MaxHeap" do
    before do
      @maxheap = Heap.new
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @maxheap.push i }
    end

    it "must satisfy the heap property" do
      @maxheap.heap?.must_equal true
      @maxheap.array.wont_equal @inserts
      @maxheap.array.wont_equal @inserts.reverse
    end

    it "must recognize heap violations" do
      @maxheap.array.unshift 0
      @maxheap.heap?.must_equal false
      @maxheap.array.shift
      @maxheap.heap?.must_equal true

      @maxheap.array.push 10
      @maxheap.heap?.must_equal false
      @maxheap.sift_up @maxheap.last_idx
      @maxheap.heap?.must_equal true
    end

    it "must pop" do
      @maxheap.pop.must_equal 10
      @maxheap.peek.wont_equal 10
      @maxheap.heap?.must_equal true
    end

    it "must heapish?" do
      @maxheap.array[0].must_be :>, @maxheap.array[1]
      @maxheap.heapish?(0, 1).must_equal true
    end

    it "must heapiest" do
      @maxheap.heapiest([1, 2]).must_equal 1
      @maxheap.heapiest([3, 4]).must_equal 4
      @maxheap.heapiest([5, 6]).must_equal 6
      @maxheap.heapiest([7, 8]).must_equal 8
    end
  end

  describe "MinHeap" do
    before do
      @minheap = Heap.new(minheap: true)
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @minheap.push i }
    end

    it "must satisfy the heap property" do
      @minheap.heap?.must_equal true
      @minheap.array.must_equal @inserts
    end

    it "must recognize heap violations" do
      @minheap.array.unshift 10
      @minheap.heap?.must_equal false
      @minheap.array.shift
      @minheap.heap?.must_equal true

      @minheap.array.push 0
      @minheap.heap?.must_equal false
      @minheap.sift_up @minheap.last_idx
      @minheap.heap?.must_equal true
    end

    it "must pop" do
      @minheap.pop.must_equal 1
      @minheap.peek.wont_equal 1
      @minheap.heap?.must_equal true
    end

    it "must heapish?" do
      @minheap.array[0].must_be :<, @minheap.array[1]
      @minheap.heapish?(0, 1).must_equal true
    end

    it "must heapiest" do
      @minheap.heapiest([1, 2]).must_equal 1
      @minheap.heapiest([3, 4]).must_equal 3
      @minheap.heapiest([5, 6]).must_equal 5
      @minheap.heapiest([7, 8]).must_equal 7
    end
  end

  describe "TernaryHeap" do
    before do
      @heap3 = Heap.new(child_slots: 3)
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @heap3.push i }
    end

    it "must satisfy the heap property" do
      @heap3.heap?.must_equal true
      @heap3.array.wont_equal @inserts
      @heap3.array.wont_equal @inserts.reverse
    end

    it "must recognize heap violations" do
      @heap3.array.unshift 0
      @heap3.heap?.must_equal false
      @heap3.array.shift
      @heap3.heap?.must_equal true

      @heap3.array.push 10
      @heap3.heap?.must_equal false
      @heap3.sift_up @heap3.last_idx
      @heap3.heap?.must_equal true
    end

    it "must pop" do
      @heap3.pop.must_equal 10
      @heap3.peek.wont_equal 10
      @heap3.heap?.must_equal true
    end

    it "must heapish?" do
      @heap3.array[0].must_be :>, @heap3.array[1]
      @heap3.heapish?(0, 1).must_equal true
    end

    it "must heapiest" do
      @heap3.heapiest([1, 2, 3]).must_equal 2
      @heap3.heapiest([4, 5, 6]).must_equal 6
      @heap3.heapiest([7, 8, 9]).must_equal 9
    end
  end
end
