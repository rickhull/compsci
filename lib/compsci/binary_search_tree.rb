require 'compsci/node'

module CompSci
  class BinarySearchTree
    # helper method; any object which responds to key, value, and children
    # may be used
    def self.node(key, val)
      CompSci::KeyNode.new(val, key: key, children: 2)
    end


    def self.create(key, val)
      self.new(self.node(key, val))
    end

    attr_reader :root

    def initialize(root_node)
      @child_slots = 2
      if root_node.children.size == @child_slots
        @root = root_node
      else
        raise "bad root: #{root_node}; expected #{@child_slots} child slots"
      end
    end

    def search_recursive(key, node: @root)
      return node if node.nil? or node.key == key
      child = key < node.key ? node.children[0] : node.children[1]
      search_recursive(key, node: child)
    end

    def search_iterative(key, node: @root)
      while !node.nil?
        return node if node.key == key
        node = key < node.key ? node.children[0] : node.children[1]
      end
      node
    end

    def insert_recursive(key, val, node: @root)
      return nil if node.nil? or node.key == key
      if key < node.key
        if node.children[0]
          insert_recursive(key, val, node: node.children[0])
        else
          node.children[0] = @root.class.new(val, key: key, children: 2)
        end
      else
        if node.children[1]
          insert_recursive(key, val, node: node.children[1])
        else
          node.children[1] = @root.class.new(val, key: key, children: 2)
        end
      end
    end
    alias_method :insert, :insert_recursive
    alias_method :[]=, :insert
  end
end
