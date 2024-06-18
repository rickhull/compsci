require 'compsci'

module CompSci
  # A CompleteTree can very efficiently use an array for storage using
  # simple arithmetic to determine parent child relationships.
  # Any type of value may be stored in the array / tree at any location.
  #
  class CompleteTree
    class WIP < RuntimeError; end

    # given a child index and child count (e.g. 2 for a binary tree)
    # integer math maps several children to one parent index
    def self.parent_idx(idx, n)
      (idx-1) / n
    end

    # given a parent index and child count
    # integer math maps several children to one parent index
    def self.children_idx(idx, n)
      Array.new(n) { |i| n*idx + i + 1 }
    end

    # how many levels deep is the given index?
    def self.gen(idx, n)
      return 0 if idx <= 0
      gen(self.parent_idx(idx, n), n) + 1
    end

    # return generation level and sibling count at that level
    def self.generation(idx, n)
      level = gen(idx, n)
      [level, n ** level]
    end

    attr_reader :array

    def initialize(array: [], child_slots: 2)
      @array = array
      @child_slots = child_slots
    end

    def push val
      @array.push val
    end

    def pop
      @array.pop
    end

    def size
      @array.size
    end

    def last_idx
      @array.size - 1 unless @array.empty?
    end

    def display(width: 80)
      result = []
      level = 0
      @array.each_with_index { |val, i|
        val = val.to_s
        level, slots = self.class.generation(i, @child_slots)
        block_width = width / slots

        # center in block_width
        space = [(block_width + val.size) / 2, val.size + 1].max
        result[level] ||= ''
        result[level] += val.ljust(space, ' ').rjust(block_width, ' ')
      }
      result
    end
    alias_method :to_s, :display
  end
end
