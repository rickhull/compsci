module CompSci
  # has a value and an array of children; allows child gaps
  class Node
    def self.display_level(nodes: [], width: 80)
      block_width = [width / nodes.size, 1].max
      nodes.map { |node|
        str = node ? node.to_s : '_'
        space = [(block_width + str.size) / 2, str.size + 1].max
        str.ljust(space, ' ').rjust(block_width, ' ')
      }.join
    end

    attr_accessor :value
    attr_reader :children

    def initialize(value, children: [])
      @value = value
      if children.is_a?(Integer)
        @children = Array.new(children)
      else
        @children = children
      end
      # @metadata = {}
    end

    def [](idx)
      @children[idx]
    end

    def []=(idx, node)
      @children[idx] = node
    end

    def to_s
      @value.to_s
    end

    def inspect
      "#<%s:0x%0xi @value=%s @children=[%s]>" %
        [self.class, self.object_id, self, @children.join(', ')]
    end

    def display(width: 80)
      levels = [self.class.display_level(nodes: [self], width: width)]
      nodes = @children
      while nodes.any? { |n| !n.nil? }
        levels << self.class.display_level(nodes: nodes, width: width)
        children = []
        nodes.each { |n|
          children += Array.new(@children.size) { |i| n and n.children[i] }
        }
        nodes = children
      end
      levels.join("\n")
    end
  end

  # adds a key to Node; often the key is used to place the node in the
  # tree, independent of the value; e.g. key=priority, value=process_id
  class KeyNode < Node
    attr_accessor :key

    def initialize(val, key: nil, children: [])
      @key = key
      super(val, children: children)
    end

    def to_s
      [@key, @value].join(':')
    end
  end

  # like Node but with a reference to its parent
  class ChildNode < Node
    attr_accessor :parent

    def initialize(value, children: [])
      @parent = nil
      super(value, children: children)
    end

    # O(log n) recursive
    def gen
      @parent ? @parent.gen + 1 : 0
    end

    def siblings
      @parent ? @parent.children : []
    end

    # update both sides of the relationship
    def []=(idx, node)
      node.parent ||= self
      raise "node has a parent: #{node.parent}" if node.parent != self
      @children[idx] = node
    end
  end


  #
  # FlexNodes - they accumulate children; no child gaps
  #

  # FlexNode API is #add_child, #add_parent, #new_child

  class FlexNode < Node
    def add_child(node)
      @children << node
    end

    def new_child(value)
      self.add_child self.class.new(value)
    end

    def add_parent(node)
      node.add_child(self)
    end
  end

  class ChildFlexNode < ChildNode
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
      @parent.add_child(self)
    end
  end
end
