require 'compsci/node'

module CompSci
  class Tree
    attr_reader :root

    def initialize(klass, val)
      @root = klass.new val
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

    def initialize(klass, val, child_slots:)
      super(klass, val)
      raise "#{klass}#parent required" unless @root.respond_to? :parent
      @child_slots = child_slots
    end

    def open_parent?(node)
      node.children.size < @child_slots
    end

    def open_parent
      @open_parent ||= @root
      return @open_parent if self.open_parent?(@open_parent)

      # TODO: ugh, there must be a better way, this is O(n)

      # try siblings first
      if @open_parent.parent
        @open_parent.parent.children.each { |c|
          return @open_parent = c if self.open_parent?(c)
        }
      end
      @open_parent = self.bf_search { |n| self.open_parent?(n) }
    end

    def push(value)
      self.open_parent.new_child value
    end

    def to_s(node: nil, width: 80)
      count = 0
      str = ''
      self.bf_search(node: node) { |n|
        count += 1
        level = Math.log(count, @child_slots).floor
        block_width = width / (@child_slots**level)
        str += "\n" if @child_slots**level == count and count > 1
        str +=
          n.to_s.ljust(block_width / @child_slots, ' ').rjust(block_width, ' ')
        false # keep searching to visit every node
      }
      str
    end
  end

  #class BinaryTree < NaryTree
  #  def initialize(klass, val)
  #    super(klass, val, child_slots: 2)
  #  end
  #end
end
