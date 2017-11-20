require 'compsci/node'

module CompSci
  #
  # FlexNodes accumulate children; no child gaps
  #

  # FlexNode API is #add_child, #add_parent, #new_child

  class FlexNode < Node
    def initialize(value, metadata: {})
      @value = value
      @children = []
      @metadata = metadata
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

    def df_search(&blk)
      return self if yield self
      stop_node = nil
      @children.each { |child|
        stop_node = child.df_search(&blk)
        break if stop_node
      }
      stop_node
    end

    def bf_search(&blk)
      destinations = [self]
      while !destinations.empty?
        node = destinations.shift
        return node if yield node
        destinations += node.children
      end
      nil
    end

    def open_parent?(child_slots)
      @children.size < child_slots
    end

    def open_parent(child_slots)
      self.bf_search { |n| n.open_parent?(child_slots) }
    end

    def push(value, child_slots)
      self.open_parent(child_slots).new_child value
    end
  end

  class ChildFlexNode < FlexNode
    attr_accessor :parent

    def initialize(value, metadata: {})
      super(value, metadata: metadata)
      @parent = nil
    end

    # O(log n) recursive
    def gen
      @parent ? @parent.gen + 1 : 0
    end

    def siblings
      @parent ? @parent.children : []
    end

    def add_child(node)
      node.parent ||= self
      raise "node has a parent: #{node.parent}" if node.parent != self
      @children << node
    end

    def add_parent(node)
      @parent = node
      @parent.add_child(self)
    end
  end
end
