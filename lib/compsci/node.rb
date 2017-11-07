module CompSci
  # has a value and an array of children; allows child gaps
  class Node
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

    def to_s
      @value.to_s
    end

    # This could be done directly with self.children, but #set_child is part
    # of the Node API.
    def set_child(idx, node)
      @children[idx] = node
    end

    def inspect
      "#<%s:0x%0xi @value=%s @children=[%s]>" %
        [self.class,
         self.object_id,
         self.to_s,
         @children.map(&:to_s).join(', ')]
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
      [key, value].join(':')
    end
  end

  # accumulate children; no child gaps
  class FlexNode < Node
    # These methods look like convenience methods, but they provide the
    # FlexNode interface also used by ChildFlexNode
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

    def set_child(idx, node)
      node.parent ||= self
      raise "node has a parent: #{node.parent}" if node.parent != self
      @children[idx] = node
    end

    def set_parent(idx, node)
      @parent = node
      @parent.set_child(idx, self)
    end
  end

  # ChildNode which accumulates children with no gaps
  # It meets the FlexNode API but does not inherit from FlexNode since it
  # needs to reimplement each method; instead get parent stuff from ChildNode
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
