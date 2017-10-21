# A Heap is a partially sorted, complete binary tree with the following
# property:
# * Every node has a value larger (or smaller) than that of its children.
#
# This class implements a heap using a simple array for storage.
# Array index math is used to find:
# * The root node (idx 0)
# * The "bottom-most" leaf node (last idx)
# * Parent idx (idx - 1 / 2)
# * Child idx (2*idx + 1, 2*idx + 2)
#
# Any Comparable may be used for node values.
# Initialize a heap with a cmp_val, either 1 for a MaxHeap or -1 for a MinHeap.
# The heap property is satisfied when a parent value equals a child value.
# Insertion (push) and removal (pop) are O(log n) where n is the heap size.
# Nodes are inserted at the end of the array, and sift_up is called to
#   reestablish the heap property.
# Nodes are removed from the start of the array, and sift_down is called to
#   reestablish the heap property.
# Sift_up and sift_down are O(log n) because they only have to check and swap
#   nodes at each layer of the tree, and there are log n layers to the tree.
#
class Heap
  # integer math says idx 2 and idx 1 both have parent at idx 0
  def self.parent_idx(idx)
    (idx-1) / 2
  end

  def self.children_idx(idx)
    [2*idx + 1, 2*idx + 2]
  end

  attr_reader :store

  # defaults to a MaxHeap, with the largest node at the root
  # specify a minheap with minheap: true or cmp_val: -1
  #
  def initialize(cmp_val: 1, minheap: false)
    cmp_val = -1 if minheap
    case cmp_val
    when -1, 1
      @cmp_val = cmp_val
    else
      raise(ArgumentError, "unknown comparison value: #{cmp_val}")
    end
    @store = []
  end

  # append to the array; sift_up
  def push(node)
    @store << node
    self.sift_up(self.last_idx)
  end

  # remove from the front of the array; move last node to root; sift_down
  def pop
    node = @store.shift
    @store.unshift(@store.pop)
    self.sift_down(0)
    node
  end

  # called recursively; idx represents the node suspected to violate the heap
  def sift_up(idx)
    return self if idx <= 0
    pidx = self.class.parent_idx(idx)
    if !self.heapish?(pidx, idx)
      @store[idx], @store[pidx] = @store[pidx], @store[idx] # swap
      self.sift_up(pidx)
    end
    self
  end

  # called recursively; idx represents the node suspected to violate the heap
  def sift_down(idx)
    return self if idx > self.last_idx
    lidx, ridx = self.class.children_idx(idx)
    # take the child most likely to be a good parent
    cidx = self.heapish?(lidx, ridx) ? lidx : ridx
    if !self.heapish?(idx, cidx)
      @store[idx], @store[cidx] = @store[cidx], @store[idx] # swap
      self.sift_down(cidx)
    end
    self
  end

  # are parent and child in accordance with heap property?
  def heapish?(pidx, cidx)
    (@store[pidx] <=> @store[cidx]) != (@cmp_val * -1)
  end

  # helper, used in 3 places
  def last_idx
    @store.length - 1
  end

  # not used internally; checks that every node satisfies the heap property
  def heap?(idx: 0)
    check_children = []
    self.class.children_idx(idx).each { |cidx|
      if cidx <= self.last_idx
        return false unless self.heapish?(idx, cidx)
        check_children << cidx
      end
    }
    check_children.each { |cidx| return false unless self.heap?(idx: cidx) }
    true
  end
end

if __FILE__ == $0
  SPEC_TEST = true
  EYEBALL_TEST = false
  INSERT_TEST = true
  BENCHMARK_TEST = true

  if SPEC_TEST
    require 'minitest/autorun'

    describe Heap do
      it "must calculate a parent index" do
        valid = {
          1 => 0,
          2 => 0,
          3 => 1,
          4 => 1,
          5 => 2,
          6 => 2,
          7 => 3,
          8 => 3,
          9 => 4,
          10 => 4,
        }

        invalid = {
          0 => -1,
          -1 => -1,
          -2 => -2,
        }
        valid.each { |idx, pidx|
          Heap.parent_idx(idx).must_equal pidx
        }
        invalid.each { |idx, pidx|
          Heap.parent_idx(idx).must_equal pidx
        }
      end

      it "must calculate children indices" do
        valid = {
          0 => [1, 2],
          1 => [3, 4],
          2 => [5, 6],
          3 => [7, 8],
          4 => [9, 10],
          5 => [11, 12],
          6 => [13, 14],
          7 => [15, 16],
          8 => [17, 18],
          9 => [19, 20],
          10 => [21, 22],
        }

        invalid = {
          -3 => [-5, -4],
          -2 => [-3, -2],
          -1 => [-1, 0],
        }

        valid.each { |idx, cidx|
          Heap.children_idx(idx).must_equal cidx
        }
        invalid.each { |idx, cidx|
          Heap.children_idx(idx).must_equal cidx
        }
      end

      describe "instance" do
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
          @minheap.store.must_equal @inserts
          @maxheap.store.wont_equal @inserts
          @maxheap.store.wont_equal @inserts.reverse
        end

        it "must recognize heap violations" do
          @minheap.store.push 0
          @minheap.heap?.must_equal false
          @minheap.sift_up @minheap.last_idx
          @minheap.heap?.must_equal true

          @minheap.store.unshift 10
          @minheap.heap?.must_equal false
          @minheap.sift_down 0
          @minheap.heap?.must_equal true

          @maxheap.store.push 10
          @maxheap.heap?.must_equal false
          @maxheap.sift_up @maxheap.last_idx
          @maxheap.heap?.must_equal true

          @maxheap.store.unshift 0
          @maxheap.heap?.must_equal false
          @maxheap.sift_down 0
          @maxheap.heap?.must_equal true
        end
      end
    end
  end

  if EYEBALL_TEST
    h = Heap.new
    99.times {
      h.push rand 99
    }
    p h.store
    p h.heap?
    puts
    max = h.pop
    puts "popped #{max}"
    p h.store
    p h.heap?
  end

  if INSERT_TEST
    count = 1
    t = Time.now
    h = Heap.new
    elapsed = 0

    while elapsed < 3
      t1 = Time.now
      h.push rand 99999
      e1 = Time.now - t1
      elapsed = Time.now - t
      count += 1
      puts "%ith insert: %0.8f s" % [count, e1] if count % 10000 == 0
    end

    puts "inserted %i items in %0.1f s" % [count, elapsed]
  end

  if BENCHMARK_TEST
    require 'minitest/autorun'
    require 'minitest/benchmark'

    describe "Heap insertion Benchmark" do
      before do
        @heap = Heap.new
      end

      bench_performance_constant "insert", 0.995 do |n|
        n.times { @heap.push rand 99999 }
      end
    end
  end
end
