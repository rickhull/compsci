require 'compsci/complete_tree'

# A Heap is a partially sorted, complete N-ary tree with the property:
# * Every node has a value larger (or smaller) than that of its children
#   (the heap property is satisfied when a parent value equals a child value)
#
# Implementation details:
# * Any Comparable may be used for node values.
# * Initialize a heap with a cmp_val, either 1 for a MaxHeap or -1 for a
#   MinHeap.
# * Insertion (push) and removal (pop) are O(logb n) where n is the heap size
#   and b is child_slots (the N in N-ary)
# * Nodes are inserted at the end of the array, and sift_up is called to
#   reestablish the heap property.
# * Nodes are removed from the start of the array, and sift_down is called to
#   reestablish the heap property.
# * Sift_up and sift_down are O(logb n) because they only have to check and
#   swap nodes at each layer of the tree, and there are log(n, base b) layers
#   to the tree.
#
class CompSci::Heap < CompSci::CompleteTree
  # * defaults to a MaxHeap, with the largest node at the root
  # * specify a minheap with minheap: true or cmp_val: -1
  #
  def initialize(cmp_val: 1, minheap: false, child_slots: 2)
    super(child_slots: child_slots)
    cmp_val = -1 if minheap
    case cmp_val
    when -1, 1
      @cmp_val = cmp_val
    else
      raise(ArgumentError, "unknown comparison value: #{cmp_val}")
    end
  end

  # * append to the array
  # * sift_up -- O(log n) on heap size
  #
  def push(node)
    @array.push(node)
    self.sift_up(@array.size - 1)
  end

  # * remove from the front of the array
  # * move last node to root
  # * sift_down -- O(log n) on heap size
  #
  def pop
    node = @array.shift
    replacement = @array.pop
    @array.unshift replacement if replacement
    self.sift_down(0)
    node
  end

  # * return what pop would return (avoid sifting)
  #
  def peek
    @array.first
  end

  # * called recursively
  # * idx represents the node suspected to violate the heap
  # * intended to be O(log n) on heap size (log base child_slots)
  #
  def sift_up(idx)
    return self if idx <= 0
    pidx = self.class.parent_idx(idx, @child_slots)
    if !self.heapish?(pidx, idx)
      @array[idx], @array[pidx] = @array[pidx], @array[idx]   # swap
      self.sift_up(pidx)
    end
    self
  end

  # * called recursively
  # * idx represents the node suspected to violate the heap
  # * intended to be O(log n) on heap size (log base child_slots)
  # * slower than sift_up because one parent vs multiple children
  #
  def sift_down(idx)
    return self if idx >= @array.size
    cidxs = self.class.children_idx(idx, @child_slots)
    # promote the heapiest child
    cidx = self.heapiest(cidxs)
    if !self.heapish?(idx, cidx)
      @array[idx], @array[cidx] = @array[cidx], @array[idx]   # swap
      self.sift_down(cidx)
    end
    self
  end

  # are values of parent and child (by index) in accordance with heap property?
  #
  def heapish?(pidx, cidx)
    (@array[pidx] <=> @array[cidx]) != (@cmp_val * -1)
  end

  # return the heapiest idx in cidxs
  #
  def heapiest(cidxs)
    idx = cidxs.first
    cidxs.each { |cidx|
      idx = cidx if cidx < @array.size and self.heapish?(cidx, idx)
    }
    idx
  end

  # * not used internally
  # * checks that every node satisfies the heap property
  # * calls heapish? on idx's children and then heap? on them recursively
  #
  def heap?(idx: 0)
    check_children = []
    self.class.children_idx(idx, @child_slots).each { |cidx|
      # cidx is arithmetically produced; the corresponding child may not exist
      if cidx < @array.size
        return false unless self.heapish?(idx, cidx)
        check_children << cidx
      end
    }
    check_children.each { |cidx| return false unless self.heap?(idx: cidx) }
    true
  end
end
