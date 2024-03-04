require 'compsci/heap'
require 'minitest/autorun'

include CompSci

describe Heap do
  parallelize_me!

  describe "MaxHeap" do
    before do
      @maxheap = Heap.new
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @maxheap.push i }
    end

    it "must satisfy the heap property" do
      expect(@maxheap.heap?).must_equal true
      expect(@maxheap.array).wont_equal @inserts
      expect(@maxheap.array).wont_equal @inserts.reverse
    end

    it "must recognize heap violations" do
      @maxheap.array.unshift 0
      expect(@maxheap.heap?).must_equal false
      @maxheap.array.shift
      expect(@maxheap.heap?).must_equal true

      @maxheap.array.push 10
      expect(@maxheap.heap?).must_equal false
      @maxheap.sift_up @maxheap.last_idx
      expect(@maxheap.heap?).must_equal true
    end

    it "must pop" do
      expect(@maxheap.pop).must_equal 10
      expect(@maxheap.peek).wont_equal 10
      expect(@maxheap.heap?).must_equal true
    end

    it "must heapish?" do
      expect(@maxheap.array[0]).must_be :>, @maxheap.array[1]
      expect(@maxheap.heapish?(0, 1)).must_equal true
    end

    it "must heapiest" do
      expect(@maxheap.heapiest([1, 2])).must_equal 1
      expect(@maxheap.heapiest([3, 4])).must_equal 4
      expect(@maxheap.heapiest([5, 6])).must_equal 6
      expect(@maxheap.heapiest([7, 8])).must_equal 8
    end
  end

  describe "MinHeap" do
    before do
      @minheap = Heap.new(minheap: true)
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @minheap.push i }
    end

    it "must satisfy the heap property" do
      expect(@minheap.heap?).must_equal true
      expect(@minheap.array).must_equal @inserts
    end

    it "must recognize heap violations" do
      @minheap.array.unshift 10
      expect(@minheap.heap?).must_equal false
      @minheap.array.shift
      expect(@minheap.heap?).must_equal true

      @minheap.array.push 0
      expect(@minheap.heap?).must_equal false
      @minheap.sift_up @minheap.last_idx
      expect(@minheap.heap?).must_equal true
    end

    it "must pop" do
      expect(@minheap.pop).must_equal 1
      expect(@minheap.peek).wont_equal 1
      expect(@minheap.heap?).must_equal true
    end

    it "must heapish?" do
      expect(@minheap.array[0]).must_be :<, @minheap.array[1]
      expect(@minheap.heapish?(0, 1)).must_equal true
    end

    it "must heapiest" do
      expect(@minheap.heapiest([1, 2])).must_equal 1
      expect(@minheap.heapiest([3, 4])).must_equal 3
      expect(@minheap.heapiest([5, 6])).must_equal 5
      expect(@minheap.heapiest([7, 8])).must_equal 7
    end
  end

  describe "TernaryHeap" do
    before do
      @heap3 = Heap.new(child_slots: 3)
      @inserts = Array.new(10) { |i| i + 1 }.each { |i| @heap3.push i }
    end

    it "must satisfy the heap property" do
      expect(@heap3.heap?).must_equal true
      expect(@heap3.array).wont_equal @inserts
      expect(@heap3.array).wont_equal @inserts.reverse
    end

    it "must recognize heap violations" do
      @heap3.array.unshift 0
      expect(@heap3.heap?).must_equal false
      @heap3.array.shift
      expect(@heap3.heap?).must_equal true

      @heap3.array.push 10
      expect(@heap3.heap?).must_equal false
      @heap3.sift_up @heap3.last_idx
      expect(@heap3.heap?).must_equal true
    end

    it "must pop" do
      expect(@heap3.pop).must_equal 10
      expect(@heap3.peek).wont_equal 10
      expect(@heap3.heap?).must_equal true
    end

    it "must heapish?" do
      expect(@heap3.array[0]).must_be :>, @heap3.array[1]
      expect(@heap3.heapish?(0, 1)).must_equal true
    end

    it "must heapiest" do
      expect(@heap3.heapiest([1, 2, 3])).must_equal 2
      expect(@heap3.heapiest([4, 5, 6])).must_equal 6
      expect(@heap3.heapiest([7, 8, 9])).must_equal 9
    end
  end
end
