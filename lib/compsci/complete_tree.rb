module CompSci
  # A CompleteNaryTree can very efficiently use an array for storage using
  # simple arithmetic to determine parent child relationships.
  #
  # It is kept separate from compsci/tree as it does not require compsci/node
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

    def to_s(width: 80)
      str = ''
      @array.each_with_index { |val, i|
        val = val.to_s
        level = Math.log(i+1, @child_slots).floor
        slots = @child_slots**level
        block_width = width / slots
        lspace = [block_width / @child_slots, val.size + 1].max
        str += "\n" if slots == i+1 and i > 0
        str += val.ljust(lspace, ' ').rjust(block_width, ' ')
      }
      str
    end
  end

  class CompleteBinaryTree < CompleteNaryTree
    def initialize(array: [])
      super(array: array, child_slots: 2)
    end
  end

  class CompleteTernaryTree < CompleteNaryTree
    def initialize(array: [])
      super(array: array, child_slots: 3)
    end
  end

  class CompleteQuaternaryTree < CompleteNaryTree
    def initialize(array: [])
      super(array: array, child_slots: 4)
    end
  end
end
