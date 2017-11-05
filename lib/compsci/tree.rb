require 'compsci/node'

module CompSci
  # for now at least, this assumes children simply stack up
  # children like: [nil, child1, child2] are not supported
  class Tree
    attr_reader :root

    def initialize(node_class, val)
      @root = node_class.new val
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

    def df_search_generic(node: nil, &blk)
      # Perform pre-order operation
      # children.each { Perform in-order operation }
      # Perform post-order operation
      puts "not defined yet"
    end
  end

  class NaryTree < Tree
    # thanks apeiros
    # https://gist.github.com/rickhull/d0b579aa08c85430b0dc82a791ff12d6
    def self.power_of?(num, base)
      return false if base <= 1
      mod = 0
      num, mod = num.divmod(base) until num == 1 || mod > 0
      mod == 0
    end

    attr_reader :child_slots

    def initialize(node_class, val, child_slots:)
      super(node_class, val)
      @child_slots = child_slots
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

    def push(value)
      self.open_parent.new_child value
    end

    def display(width: nil)
      str = ''
      old_level = 0
      width ||= @child_slots * 40
      self.bf_search { |node|
        raise "#{node.class} not yet supported" unless node.respond_to? :gen
        level = node.gen
        if old_level != level
          str += "\n"
          old_level = level
        end
        # center in block_width
        slots = @child_slots**level
        block_width = width / slots
        val = node.to_s
        space = [(block_width + val.size) / 2, val.size + 1].max
        str += val.ljust(space, ' ').rjust(block_width, ' ')
        false
      }
      str
    end
    alias_method :to_s, :display
  end

  class BinaryTree < NaryTree
    def initialize(node_class, val)
      super(node_class, val, child_slots: 2)
    end

    def display(width: 80)
      count = 0
      str = ''
      self.bf_search { |node|
        count += 1
        level = Math.log(count, 2).floor
        block_width = width / (2**level)
        val = node.to_s
        str += "\n" if 2**level == count and count > 1
        space = [(block_width + val.size) / 2, val.size + 1].max
        str += val.ljust(space, ' ').rjust(block_width, ' ')
        false # keep searching to visit every node
      }
      str
    end
    alias_method :to_s, :display
  end

  class TernaryTree < NaryTree
    def initialize(node_class, val)
      super(node_class, val, child_slots: 3)
    end
  end

  class QuaternaryTree < NaryTree
    def initialize(node_class, val)
      super(node_class, val, child_slots: 4)
    end
  end
end
