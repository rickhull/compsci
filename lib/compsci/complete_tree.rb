module CompSci
  # A CompleteBinaryTree can very efficiently use an array for storage using
  # simple arithmetic to determine parent child relationships.
  #
  # Likewise, we should be able to use an array for N children
  #
  class CompleteNaryTree
    def self.parent_idx(idx, n)
      (idx-1) / n
    end

    def self.children_idx(idx, n)
      Array.new(n) { |i| n*idx + i + 1 }
    end

    attr_reader :store

    def initialize(store: [], child_slots: 2)
      @store = store
      @child_slots = child_slots
    end

    def push node
      @store.push node
    end

    def pop
      @store.pop
    end

    def size
      @store.size
    end

    def last_idx
      @store.size - 1 unless @store.empty?
    end
  end

  # BinaryHeap still expects CompleteBinaryTree
  #
  class CompleteBinaryTree < CompleteNaryTree
    # integer math says idx 2 and idx 1 both have parent at idx 0
    def self.parent_idx(idx)
      (idx-1) / 2
    end

    def self.children_idx(idx)
      [2*idx + 1, 2*idx + 2]
    end

    attr_reader :store

    def initialize(store: [])
      super(store: store, child_slots: 2)
    end

    # TODO: generalize for N != 2
    def to_s(node: nil, width: 80)
      str = ''
      @store.each_with_index { |n, i|
        level = Math.log(i+1, 2).floor
        block_width = width / (2**level)
        str += "\n" if 2**level == i+1 and i > 0
        str += n.to_s.ljust(block_width / 2, ' ').rjust(block_width, ' ')
      }
      str
    end
  end
end
