require 'compsci/node'

module CompSci
  class Tree
    attr_reader :root

    def initialize(node_class, val)
      @root = node_class.new val
    end

    def df_search(node: nil, &blk)
      node ||= @root
      return node if yield node
      node.children.each { |c|
        stop_node = self.df_search(node: c, &blk)
        return stop_node if stop_node
      }
      nil
    end

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
    attr_reader :child_slots

    def initialize(node_class, val, child_slots:)
      super(node_class, val)
      @child_slots = child_slots
    end

    def open_parent?(node)
      node.children.size < @child_slots
    end

    def open_parent
      @open_parent ||= @root
      return @open_parent if self.open_parent?(@open_parent)

      # TODO: ugh, there must be a better way, bf_search is O(n)

      # try siblings first, only possible with Node#parent
      if @open_parent.respond_to?(:parent) and @open_parent.parent
        @open_parent.parent.children.each { |c|
          return @open_parent = c if self.open_parent?(c)
        }
      end
      @open_parent = self.bf_search { |n| self.open_parent?(n) }
    end

    def push(value)
      self.open_parent.new_child value
    end

    def display(width: nil)
      count = 0
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
      self.bf_search { |n|
        count += 1
        level = Math.log(count, 2).floor
        block_width = width / (2**level)
        str += "\n" if 2**level == count and count > 1
        str += n.to_s.ljust(block_width / 2, ' ').rjust(block_width, ' ')
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
