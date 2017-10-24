require 'compsci'

module CompSci
  class BinaryTree
    attr_reader :root

    def initialize(root: nil, value: nil)
      if root
        @root = root
      elsif value
        @root = Node.new value
      else
        raise "a root node is required"
      end
      @open_parent = @root
    end

    def push(value)
      self.open_parent.new_child value
    end

    def open_parent
      return @open_parent if @open_parent.open?
      @open_parent = self.bf_search { |n| n.open? }
    end

    def df_search(node: nil, &blk)
      node ||= @root
      puts "visited #{node}"
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
    end

    def bf_print(node: nil, width: 80)
      count = 0
      self.bf_search(node: node) { |n|
        count += 1
        str = n.to_s
        level = Math.log(count, 2).floor
        block_width = width / (2**level)
        puts if 2**level == count and count > 1
        print n.to_s.ljust(block_width / 2, ' ').rjust(block_width, ' ')
      }
      puts
    end

    class Node
      attr_accessor :value, :parent
      attr_reader :left, :right

      def initialize(value)
        @value = value
        @parent = nil
        @left = nil
        @right = nil
        # @metadata = {}
      end

      def add_child(node)
        if @left.nil?
          @left = node
          @left.parent = self
        elsif @right.nil?
          @right = node
          @right.parent = self
        else
          raise("no child slot available for #{node}")
        end
      end

      def new_child(value)
        self.add_child self.class.new value
      end

      def add_parent(node)
        node.add_child(self)
      end

      def open?
        @left.nil? or @right.nil?
      end

      def children
        [@left, @right].compact
      end

      def to_s
        @value.to_s
      end

      def inspect
        "#<Node: %s @left=%s @right=%s>" % [@value.to_s,
                                            @left.inspect,
                                            @right.inspect]
      end
    end
  end

  class CompleteBinaryTree
    # integer math says idx 2 and idx 1 both have parent at idx 0
    def self.parent_idx(idx)
      (idx-1) / 2
    end

    def self.children_idx(idx)
      [2*idx + 1, 2*idx + 2]
    end

    attr_reader :store

    def initialize
      @store = []
    end

    def size
      @store.size
    end

    def last_idx
      self.size - 1 unless @store.empty?
    end
  end
end
