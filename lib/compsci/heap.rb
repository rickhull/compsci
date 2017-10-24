require 'compsci/binary_tree'

# A Heap is a partially sorted, complete binary tree with the property:
# * Every node has a value larger (or smaller) than that of its children.
#
# This class implements a heap using a simple array for storage.
# Array index math is used to find:
# * The root node (idx 0)
# * The "bottom-most" leaf node (last idx)
# * Parent idx (idx-1 / 2)
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
class CompSci::Heap < CompSci::CompleteBinaryTree
  # defaults to a MaxHeap, with the largest node at the root
  # specify a minheap with minheap: true or cmp_val: -1
  #
  def initialize(cmp_val: 1, minheap: false)
    super()
    cmp_val = -1 if minheap
    case cmp_val
    when -1, 1
      @cmp_val = cmp_val
    else
      raise(ArgumentError, "unknown comparison value: #{cmp_val}")
    end
  end

  # append to the array; sift_up
  def push(node)
    @store << node
    self.sift_up(self.last_idx)
  end

  # remove from the front of the array; move last node to root; sift_down
  def pop
    node = @store.shift
    replacement = @store.pop
    @store.unshift replacement if replacement
    self.sift_down(0)
    node
  end

  # return what pop would return
  def peek
    @store.first
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

  # are values of parent and child (by index) in accordance with heap property?
  def heapish?(pidx, cidx)
    (@store[pidx] <=> @store[cidx]) != (@cmp_val * -1)
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
