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
      @open_parent = self.walk_until { |n| n.open? }
    end

    def walk_until(node: nil, &blk)
      node ||= @root
      return node if yield node
      if node.left
        left_node = self.walk_until(node: node.left, &blk)
        return left_node if left_node
      end
      if node.right
        right_node = self.walk_until(node: node.right, &blk)
        return right_node if right_node
      end
    end

    class Node
      attr_accessor :value, :parent
      attr_reader :left, :right

      def initialize(value)
        @value = value
        @parent = nil
        @left = nil
        @right = nil
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
        "#<%s:0x%0x @value=%s @left=%s @right=%s>" % [self.class.name,
                                                    self.object_id,
                                                    value.to_s,
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

    def last_idx
      @store.length - 1 unless @store.empty?
    end
  end
end
