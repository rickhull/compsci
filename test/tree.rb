require 'compsci/tree'
require 'minitest/autorun'

include CompSci

describe Tree do
  before do
    @tree = Tree.new(FlexNode, 42)
    @vals = Array.new(99) { rand 99 }
  end

  it "is populated via the root node" do
    @vals.each { |v| @tree.root.new_child v }
    @tree.root.children.size.must_equal @vals.size
  end

  it "does depth_first search" do
    vals = (0..30).to_a
    tree = Tree.new(FlexNode, vals.shift)
    tree.root.new_child vals.shift
    tree.root.new_child vals.shift
    tree.root.children.each { |c|
      c.new_child vals.shift
      c.new_child vals.shift

      c.children.each { |cc|
        cc.new_child vals.shift
        cc.new_child vals.shift
      }
    }

    visited = []
    tree.df_search { |n|
      visited << n.value
      false
    }
    visited.wont_be_empty
    visited.must_equal [0, 1, 3, 5, 6, 4, 7, 8, 2, 9, 11, 12, 10, 13, 14]
  end

  it "does breadth_first search" do
    vals = (0..30).to_a
    tree = Tree.new(FlexNode, vals.shift)
    tree.root.new_child vals.shift
    tree.root.new_child vals.shift
    tree.root.children.each { |c|
      c.new_child vals.shift
      c.new_child vals.shift

      c.children.each { |cc|
        cc.new_child vals.shift
        cc.new_child vals.shift
      }
    }

    visited = []
    tree.bf_search { |n|
      visited << n.value
      false
    }
    visited.wont_be_empty
    visited.must_equal [0, 1, 2, 3, 4, 9, 10, 5, 6, 7, 8, 11, 12, 13, 14]
  end
end

describe NaryTree do
  it "must power_of?" do
    powers = {}
    basemax = 12
    expmax = 10
    2.upto(basemax) { |base|
      0.upto(expmax) { |exp|
        powers[base] ||= []
        powers[base] << base**exp
      }
    }

    # 12k assertions below!
    2.upto(basemax) { |base|
      1.upto(2**expmax) { |num|
        if powers[base].include?(num)
          NaryTree.power_of?(num, base).must_equal true
        else
          NaryTree.power_of?(num, base).must_equal false
        end
      }
    }
  end

  describe "with FlexNode" do
    before do
      @tree = NaryTree.new(FlexNode, 42, child_slots: 3)
    end

    it "must have an open parent" do
      @tree.open_parent?(@tree.root).must_equal true
      @tree.open_parent?(@tree.open_parent).must_equal true
    end

    it "must push a value onto an open parent" do
      op = @tree.open_parent
      opc = op.children.size
      @tree.push 5
      @tree.open_parent.children.size.must_equal opc + 1
    end
  end

  describe "with ChildFlexNode" do
    before do
      @tree = NaryTree.new(ChildFlexNode, 42, child_slots: 4)
    end

    it "must have an open parent" do
      @tree.open_parent?(@tree.root).must_equal true
      @tree.open_parent?(@tree.open_parent).must_equal true
    end

    it "must push a value onto an open parent" do
      op = @tree.open_parent
      opc = op.children.size
      @tree.push 5
      @tree.open_parent.children.size.must_equal opc + 1
    end
  end
end

describe "BinaryTree" do
  before do
    @tree = BinaryTree.new(FlexNode, 42)
  end

  it "must have 2 child_slots" do
    @tree.child_slots.must_equal 2
  end

  it "must to_s" do
    item_count = 31
    # tree already has a root node
    (item_count - 1).times { @tree.push rand 99 }
    str = @tree.to_s
    line_count = str.split("\n").size
    line_count.must_equal Math.log(item_count + 1, 2).ceil
  end

  describe "searching" do
    before do
      @tree = NaryTree.new(FlexNode, 42, child_slots: 2)
      99.times { |i| @tree.push i }
    end

    it "must find 42 quickly" do
      count = 0
      @tree.df_search { |n|
        count += 1
        n.value == 42
      }.must_equal @tree.root
      count.must_equal 1

      count = 0
      @tree.bf_search { |n|
        count += 1
        n.value == 42
      }.must_equal @tree.root
      count.must_equal 1
    end

    it "must find 99 slowly" do
      count = 0
      @tree.df_search { |n|
        count += 1
        n.value == 99
      }
      count.must_equal 100

      count = 0
      @tree.bf_search { |n|
        count += 1
        n.value == 99
      }
      count.must_equal 100
    end

    it "must find 81 accordingly" do
      count = 0
      @tree.df_search { |n|
        count += 1
        n.value == 81
      }
      count.must_equal 42

      count = 0
      @tree.bf_search { |n|
        count += 1
        n.value == 81
      }
      count.must_equal 83
    end
  end
end
