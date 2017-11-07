require 'compsci/node'
require 'compsci/tree'

module CompSci
  class BinarySearchTree < BinaryTree
    def self.display_level(nodes: [], width: 80)
      unless self.power_of?(nodes.size, 2)
        raise "unexpected node count: #{nodes.size}"
      end
      block_width = [width / nodes.size, 1].max
      nodes.map { |node|
        str = node ? node.to_s : '_'
        space = [(block_width + str.size) / 2, str.size + 1].max
        str.ljust(space, ' ').rjust(block_width, ' ')
      }.join
    end

    # helper method; any object which responds to key, value, and children
    # may be used
    def self.new_node(key, val)
      CompSci::KeyNode.new(val, key: key, children: 2)
    end

    def self.new_with_kv(key, val)
      self.new(self.new_node(key, val))
    end

    def initialize(root_node)
      @node_class = root_node.class
      @child_slots = 2
      if root_node.children.size == @child_slots
        @root = root_node
      else
        raise "bad root: #{root_node}; expected #{@child_slots} child slots"
      end
    end

    def search_recursive(key, node: @root)
      return node if node.nil? or node.key == key
      child = node.key < key ? node.children[0] : node.children[1]
      search_recursive(key, node: child)
    end

    def search_iterative(key, node: @root)
      while !node.nil?
        return node if node.key == key
        node = node.key < key ? node.children[0] : node.children[1]
      end
      node
    end

    def insert_recursive(key, val, node: @root)
      return nil if node.nil? or node.key == key
      if key < node.key
        if node.children[0]
          insert_recursive(key, val, node: node.children[0])
        else
          node.children[0] = @node_class.new(val, key: key, children: 2)
        end
      else
        if node.children[1]
          insert_recursive(key, val, node: node.children[1])
        else
          node.children[1] = @node_class.new(val, key: key, children: 2)
        end
      end
    end
    alias_method :insert, :insert_recursive
    alias_method :[]=, :insert

    def display(node: @root, width: 80)
      levels = [self.class.display_level(nodes: [node], width: width)]
      nodes = node.children
      while nodes.any? { |n| !n.nil? }
        levels << self.class.display_level(nodes: nodes, width: width)
        children = []
        nodes.each { |n|
          children += n ? n.children : Array.new(@child_slots)
        }
        nodes = children
      end
      levels.join("\n")
    end
    alias_method :to_s, :display
  end
end
