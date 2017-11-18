# require 'compsci/node'

module CompSci
  class NaryTree
    def self.xdisplay_level(nodes: [], width: 80)
      block_width = [width / nodes.size, 1].max
      nodes.map { |node|
        str = node ? node.to_s : '_'
        space = [(block_width + str.size) / 2, str.size + 1].max
        str.ljust(space, ' ').rjust(block_width, ' ')
      }.join
    end

    attr_reader :root, :child_slots

    def initialize(root_node, child_slots:)
      @root = root_node
      @child_slots = child_slots
    end

    def xdisplay(node: @root, width: 80)
      levels = [self.class.display_level(nodes: [node], width: width)]
      nodes = node.children
      while nodes.any? { |n| !n.nil? }
        levels << self.class.display_level(nodes: nodes, width: width)
        children = []
        nodes.each { |n|
          children += Array.new(@child_slots) { |i| n and n.children[i] }
        }
        nodes = children
      end
      levels.join("\n")
    end

    def display(width: 80)
      @root.display(width: width)
    end
    alias_method :to_s, :display
  end

  class BinaryTree < NaryTree
    def initialize(root_node)
      super(root_node, child_slots: 2)
    end
  end

  class TernaryTree < NaryTree
    def initialize(root_node)
      super(root_node, child_slots: 3)
    end
  end

  class QuaternaryTree < NaryTree
    def initialize(root_node)
      super(root_node, child_slots: 4)
    end
  end

  # FlexNode based trees allow Tree#push
  class PushTree < NaryTree
    def initialize(root_node, child_slots:)
      super(root_node, child_slots: child_slots)
      raise "@root#new_child required" unless @root.respond_to? :new_child
    end

    # this only works if @root.respond_to? :new_child
    def push(value)
      self.open_parent.new_child value
    end

    # does not support children gaps
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

    # does not support children gaps
    def df_search(node: nil, &blk)
      node ||= @root
      return node if yield node
      node.children.each { |c|
        stop_node = self.df_search(node: c, &blk)
        return stop_node if stop_node
      }
      nil
    end

    def open_parent?(node)
      node.children.size < @child_slots
    end

    def open_sibling
      # try siblings first, only possible with Node#parent
      if @open_parent.respond_to?(:siblings)
        @open_parent.siblings.find { |s| self.open_parent?(s) }
      end
    end

    def open_parent
      @open_parent ||= @root
      return @open_parent if self.open_parent?(@open_parent)
      open_sibling = self.open_sibling
      return @open_parent = open_sibling if open_sibling
      @open_parent = self.bf_search { |n| self.open_parent?(n) }
    end
  end
end
