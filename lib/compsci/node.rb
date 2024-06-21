module CompSci
  # has a value and an array of children; allows child gaps
  class Node
    def self.display_line(nodes: [], width: 80)
      block_width = [width / nodes.size, 1].max
      nodes.map { |node|
        str = node ? node.to_s : '_'
        space = [(block_width + str.size) / 2, str.size + 1].max
        str.ljust(space, ' ').rjust(block_width, ' ')
      }.join
    end

    attr_accessor :value, :metadata
    attr_reader :children

    def initialize(value, children: 2, metadata: {})
      @value = value
      @children = Array.new(children)
      @metadata = metadata
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
      lines = [self.class.display_line(nodes: [self], width: width)]
      nodes = @children
      while nodes.any? { |n| !n.nil? }
        lines << self.class.display_line(nodes: nodes, width: width)
        if nodes.size > 3**7
          lines << "nodes.size = #{nodes.size}; abort render"
          break
        end
        nodes = nodes.reduce([]) { |memo, n|
          memo + Array.new(@children.size) { |i| n and n.children[i] }
        }
      end
      lines
    end
  end

  # TODO: implement key with @metadata !?!?!?!?

  # adds a key to Node; often the key is used to place the node in the
  # tree, independent of the value; e.g. key=priority, value=process_id
  class KeyNode < Node
    class DuplicateKey < RuntimeError; end
    class SearchError < RuntimeError; end

    attr_reader :key, :duplicates

    def self.key_cmp_idx(new_key, key, child_slots: 2, duplicates: false)
      if child_slots < 2
        raise(ArgumentError, "child_slots: #{child_slots} too small")
      elsif child_slots == 2
        raise(DuplicateKey, "#{new_key}") if new_key == key and !duplicates
        new_key < key ? 0 : 1
      elsif child_slots == 3
        (new_key <=> key) + 1
      else
        raise(ArgumentError: "child_slots: #{child_slots} too big")
      end
    end

    def initialize(val, key: nil, children: 2, duplicates: false)
      super(val, children: children)
      @key, @duplicates = key, duplicates
    end

    def to_s
      [@key, @value].join(':')
    end

    # which child idx should handle key?
    def cidx(key)
      self.class.key_cmp_idx(key, @key,
                             child_slots: @children.size,
                             duplicates: @duplicates)
    end

    # works for 2 or 3 children
    def insert(key, val)
      idx = self.cidx(key)
      if @children[idx]
        @children[idx].insert(key, val)
      else
        @children[idx] = self.class.new(val, key: key,
                                        children: @children.size,
                                        duplicates: @duplicates)
      end
    end

    # returns a single node for binary search
    # returns multiple nodes for ternary search
    def search(key)
      if @children.size == 2
        self.search2(key)
      elsif @children.size == 3
        self.search3(key)
      else
        raise(SearchError, "can't search for @children.size children")
      end
    end

    # returns a single node or nil
    def search2(key)
      return self if key == @key
      child = @children[self.cidx(key)]
      child.search(key) if child
    end

    # returns an array of nodes, possibly empty
    def search3(key)
      if key == @key
        nodes = [self]
        node = @children[1]
        while node
          nodes << node
          node = node.children[1]
        end
        return nodes
      end
      child = @children[self.cidx(key)]
      child ? child.search(key) : []
    end
  end

  # like Node but with a reference to its parent
  class ChildNode < Node
    attr_accessor :parent

    def initialize(value, children: 2)
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
end
