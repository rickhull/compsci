module CompSci
  # has a value and an array of children
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
end
