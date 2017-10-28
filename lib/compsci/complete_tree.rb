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

    def self.gen(idx, n)
      count = 0
      loop {
        pidx = self.parent_idx(idx, n)
        break if pidx < 0
        count += 1
        idx = pidx
      }
      count
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

    # or, ya know, just iterate @array
    def bf_search(&blk)
      destinations = [0]
      while !destinations.empty?
        idx = destinations.shift
        return idx if yield @array[idx]

        # idx has a val and the block is false
        # add existent children to destinations
        self.class.children_idx(idx, @child_slots).each { |cidx|
          destinations.push(cidx) if cidx < @array.size
        }
      end
    end

    def df_search(&blk)
      puts "not yet"
    end

    def display(width: nil)
      str = ''
      old_level = 0
      width ||= @child_slots * 40
      @array.each_with_index { |val, i|
        val = val.to_s
        level = self.class.gen(i, @child_slots)
        if old_level != level
          str += "\n"
          old_level = level
        end

        # center in block_width
        slots = @child_slots**level
        block_width = width / slots
        space = [(block_width + val.size) / 2, val.size + 1].max
        str += val.ljust(space, ' ').rjust(block_width, ' ')
      }
      str
    end
    alias_method :to_s, :display
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
