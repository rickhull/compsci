require 'compsci'

module CompSci
  class Node
    attr_accessor :value
    attr_reader :children

    def initialize(value)
      @value = value
      @children = []
      # @metadata = {}
    end

    def add_child(node)
      @children << node
    end

    def new_child(value)
      self.add_child self.class.new(value)
    end

    def add_parent(node)
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

  # like Node but with a reference to its parent
  class ChildNode < Node
    attr_accessor :parent

    def initialize(value)
      @parent = nil
      super(value)
    end

    def add_child(node)
      node.parent ||= self
      raise "node has a parent: #{node.parent}" if node.parent != self
      super(node)
    end

    def add_parent(node)
      @parent = node
      super(node)
    end
  end

  class Tree
    attr_reader :root

    def initialize(klass, val)
      @root = klass.new val
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

    def df_search_generic(node: nil, &blk)
      # Perform pre-order operation
      # children.each { Perform in-order operation }
      # Perform post-order operation
      puts "not defined yet"
    end
  end

  class NaryTree < Tree
    attr_reader :child_slots

    def initialize(klass, val, child_slots:)
      super(klass, val)
      raise "#{klass}#parent required" unless @root.respond_to? :parent
      @child_slots = child_slots
    end

    def open_parent?(node)
      node.children.size < @child_slots
    end

    def open_parent
      @open_parent ||= @root
      return @open_parent if self.open_parent?(@open_parent)

      # TODO: ugh, there must be a better way, this is O(n)

      # try siblings first
      if @open_parent.parent
        @open_parent.parent.children.each { |c|
          return @open_parent = c if self.open_parent?(c)
        }
      end
      @open_parent = self.bf_search { |n| self.open_parent?(n) }
    end

    def push(value)
      self.open_parent.new_child value
    end
  end

  class BinaryTree < NaryTree
    def initialize(klass, val)
      super(klass, val, child_slots: 2)
    end

    def to_s(node: nil, width: 80)
      count = 0
      str = ''
      self.bf_search(node: node) { |n|
        count += 1
        level = Math.log(count, 2).floor
        block_width = width / (2**level)
        str += "\n" if 2**level == count and count > 1
        str += n.to_s.ljust(block_width / 2, ' ').rjust(block_width, ' ')
        false # keep searching to visit every node
      }
      str
    end
  end

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

  # Heap still expects CompleteBinaryTree
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
  end
end
