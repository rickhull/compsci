require 'compsci'

module CompSci
  class Tree
    attr_reader :root, :child_slots

    def initialize(root_node, child_slots: 2)
      @root = root_node
      @child_slots = child_slots
      @open_parent = @root
    end

    def push(value)
      self.open_parent.new_child value
    end

    def open_parent?(node)
      node.children.size < @child_slots
    end

    def open_parent
      return @open_parent if self.open_parent?(@open_parent)
      @open_parent = self.bf_search { |n| self.open_parent?(n) }
    end

    def df_search(node: nil, &blk)
      node ||= @root
      return node if yield node
      node.children.each { |c|
        stop_node = self.df_search(node: c, &blk)
        return stop_node if stop_node
      }
      nil
    end

    def df_search_generic(node: nil, &blk)
      # Perform pre-order operation
      # children.each { Perform in-order operation }
      # Perform post-order operation
      puts "not defined yet"
    end

    def bf_search(node: nil, &blk)
      node ||= @root
      destinations = [node]
      while !destinations.empty?
        node = destinations.shift
        return node if yield node
        destinations += node.children
      end
      nil
    end

    class Node
      attr_accessor :value, :parent
      attr_reader :children

      def initialize(value)
        @value = value
        @parent = nil
        @children = []
        # @metadata = {}
      end

      def add_child(node)
        node.parent ||= self
        raise "node has a parent: #{node.parent}" if node.parent != self
        @children << node
      end

      def new_child(value)
        self.add_child self.class.new(value)
      end

      def add_parent(node)
        @parent = node
        node.add_child(self)
      end

      def to_s
        @value.to_s
      end

      def inspect
        "#<%s:0x%0xi @value=%s @children=[%s]>" %
          [self.class,
           self.object_id,
           self.to_s,
           @children.map(&:to_s).join(', ')]
      end
    end
  end

  class BinaryTree < Tree
    def initialize(root_node)
      super(root_node, child_slots: 2)
    end

    def bf_print(node: nil, width: 80)
      count = 0
      self.bf_search(node: node) { |n|
        count += 1
        level = Math.log(count, 2).floor
        block_width = width / (2**level)
        puts if 2**level == count and count > 1
        print n.to_s.ljust(block_width / 2, ' ').rjust(block_width, ' ')
      }
      puts
    end
  end

  # A CompleteBinaryTree can very efficiently use an array for storage using
  # simple arithmetic to determine parent child relationships.
  #
  class CompleteBinaryTree
    # integer math says idx 2 and idx 1 both have parent at idx 0
    def self.parent_idx(idx)
      (idx-1) / 2
    end

    def self.children_idx(idx)
      [2*idx + 1, 2*idx + 2]
    end

    attr_reader :store

    def initialize(store: [])
      @store = store
      # yield self if block_given?
    end

    def size
      @store.size
    end

    def last_idx
      @store.size - 1 unless @store.empty?
    end
  end
end
