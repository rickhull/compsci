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

    def initialize(val)
      @root = Node.new(val, children: 2)
      @child_slots = 2
    end

    def search_recursive(val, node: @root)
      return node if node.nil? or node.value == val
      child = node.value < val ? node.children[0] : node.children[1]
      search_recursive(val, node: child)
    end

    def search_iterative(val, node: @root)
      while !node.nil?
        return node if node.value == val
        node = node.value < val ? node.children[0] : node.children[1]
      end
      node
    end

    def insert_recursive(val, node: @root)
      return nil if node.nil? or node.value == val
      if val < node.value
        if node.children[0]
          insert_recursive(val, node: node.children[0])
        else
          node.children[0] = Node.new(val, children: 2)
        end
      else
        if node.children[1]
          insert_recursive(val, node: node.children[1])
        else
          node.children[1] = Node.new(val, children: 2)
        end
      end
    end
    alias_method :insert, :insert_recursive

    def display(node: @root, width: 80)
      levels = [self.class.display_level(nodes: [node], width: width)]
      nodes = node.children
      while !nodes.all? { |n| n.nil? }
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
