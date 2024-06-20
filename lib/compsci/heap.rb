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
module CompSci
  class Heap
    attr_reader :tree, :cmp_val

    # * defaults to a MaxHeap, with the largest node at the root
    # * specify a minheap with minheap: true or cmp_val: -1
    #
    def initialize(cmp_val: 1, minheap: false, child_slots: 2)
      @tree = CompleteTree.new(child_slots: child_slots)
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
      @tree.push(node)
      self.sift_up(@tree.size - 1)
    end

    # * remove from the front of the array
    # * move last node to root
    # * sift_down -- O(log n) on heap size
    #
    def pop
      node = @tree.shift
      replacement = @tree.pop
      @tree.unshift replacement if replacement
      self.sift_down(0)
      node
    end

    # * called recursively
    # * idx represents the node suspected to violate the heap
    # * intended to be O(log n) on heap size (log base child_slots)
    #
    def sift_up(idx = @tree.size - 1)
      return self if idx <= 0
      pidx = @tree.class.parent_idx(idx, @tree.child_slots)
      if !heapish?(pidx, idx)
        @tree.swap(idx, pidx)
        sift_up(pidx)
      end
      self
    end

    # * called recursively
    # * idx represents the node suspected to violate the heap
    # * intended to be O(log n) on heap size (log base child_slots)
    # * slower than sift_up because one parent vs multiple children
    #
    def sift_down(idx = 0)
      return self if idx >= @tree.size
      cidxs = @tree.class.children_idx(idx, @tree.child_slots)
      # promote the heapiest child
      if (cidx = self.heapiest(cidxs)) and !self.heapish?(idx, cidx)
        @tree.swap(idx, cidx)
        self.sift_down(cidx)
      end
      self
    end

    # do values of parent and child (by index) meet the heap test?
    #
    def heapish?(pidx, cidx)
      (@tree[pidx] <=> @tree[cidx]) != (@cmp_val * -1)
    end

    # return the heapiest idx in cidxs
    #
    def heapiest(cidxs)
      idx = cidxs.first or return nil
      cidxs.each { |cidx|
        idx = cidx if cidx < @tree.size and heapish?(cidx, idx)
      }
      idx
    end

    # * not used internally
    # * checks that every node satisfies the heap property
    # * calls heapish? on idx's children and then heap? on them recursively
    #
    def heap?(idx: 0)
      check_children = Array.new
      @tree.class.children_idx(idx, @tree.child_slots).each { |cidx|
        # cidx may not be valid
        if cidx < @tree.size
          return false unless heapish?(idx, cidx)
          check_children << cidx
        end
      }
      check_children.each { |cidx| return false unless self.heap?(idx: cidx) }
      true
    end

    def size
      @tree.size
    end
    alias_method :count, :size
  end
end
