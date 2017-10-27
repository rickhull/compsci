module CompSci
  # A CompleteNaryTree can very efficiently use an array for storage using
  # simple arithmetic to determine parent child relationships.
  #
  class CompleteNaryTree
    def self.parent_idx(idx, n)
      (idx-1) / n
    end

    def self.children_idx(idx, n)
      Array.new(n) { |i| n*idx + i + 1 }
    end

    attr_reader :array

    def initialize(array: [], child_slots: 2)
      @array = array
      @child_slots = child_slots
    end

    def push node
      @array.push node
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

    def to_s(node: nil, width: 80)
      str = ''
      @array.each_with_index { |n, i|
        level = Math.log(i+1, @child_slots).floor
        block_width = width / (@child_slots**level)
        str += "\n" if @child_slots**level == i+1 and i > 0
        str +=
          n.to_s.ljust(block_width / @child_slots, ' ').rjust(block_width, ' ')
      }
      str
    end
  end
end
