require 'compsci/tree'
require 'minitest/autorun'

include CompSci

describe Node do
  before do
    @martin_sheen = Node.new 'martin'
    @charlie_sheen = Node.new 'charlie'
    @emilio_estevez = Node.new 'emilio'
  end

  it "must start with no children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.children.must_be_empty
    }
  end

  it "must track children" do
    @charlie_sheen.add_parent(@martin_sheen)
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    @martin_sheen.children.size.must_equal 1
    @martin_sheen.children.first.value.must_equal 'fake_emilio'
    @martin_sheen.children.wont_include @emilio_estevez
  end
end

describe ChildNode do
  before do
    @martin_sheen = ChildNode.new 'martin'
    @charlie_sheen = ChildNode.new 'charlie'
    @emilio_estevez = ChildNode.new 'emilio'
  end

  it "must start with neither parent nor children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.parent.nil?.must_equal true
      n.children.must_be_empty
    }
  end

  it "must track parent and children" do
    @charlie_sheen.add_parent(@martin_sheen)
    @charlie_sheen.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
    @emilio_estevez.parent.must_equal @martin_sheen
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    @martin_sheen.children.size.must_equal 1
    @martin_sheen.children.first.value.must_equal 'fake_emilio'
    @martin_sheen.children.wont_include @emilio_estevez
  end
end

describe Tree do
  before do
    @tree = Tree.new(Node, 42)
    @vals = Array.new(99) { rand 99 }
  end

  it "is populated via the root node" do
    @vals.each { |v| @tree.root.new_child v }
    @tree.root.children.size.must_equal @vals.size
  end

  it "does depth_first search" do
    vals = (0..30).to_a
    tree = Tree.new(Node, vals.shift)
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
    tree = Tree.new(Node, vals.shift)
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
  before do
    @tree = NaryTree.new(ChildNode, 42, child_slots: 3)
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

  describe "searching" do
    before do
      @tree = NaryTree.new(ChildNode, 42, child_slots: 2)
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

describe BinaryTree do
  before do
    @tree = BinaryTree.new(ChildNode, 42)
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
end

describe CompleteBinaryTree do
  it "must calculate a parent index" do
    valid = {
      1 => 0,
      2 => 0,
      3 => 1,
      4 => 1,
      5 => 2,
      6 => 2,
      7 => 3,
      8 => 3,
      9 => 4,
      10 => 4,
    }

    invalid = {
      0 => -1,
      -1 => -1,
      -2 => -2,
    }
    valid.each { |idx, pidx|
      CompleteBinaryTree.parent_idx(idx).must_equal pidx
    }
    invalid.each { |idx, pidx|
      CompleteBinaryTree.parent_idx(idx).must_equal pidx
    }
  end

  it "must calculate children indices" do
    valid = {
      0 => [1, 2],
      1 => [3, 4],
      2 => [5, 6],
      3 => [7, 8],
      4 => [9, 10],
      5 => [11, 12],
      6 => [13, 14],
      7 => [15, 16],
      8 => [17, 18],
      9 => [19, 20],
      10 => [21, 22],
    }

    invalid = {
      -3 => [-5, -4],
      -2 => [-3, -2],
      -1 => [-1, 0],
    }

    valid.each { |idx, cidx|
      CompleteBinaryTree.children_idx(idx).must_equal cidx
    }
    invalid.each { |idx, cidx|
      CompleteBinaryTree.children_idx(idx).must_equal cidx
    }
  end

  describe "instance" do
    before do
      @array = (0..99).sort_by { rand }
      @empty = CompleteBinaryTree.new
      @nonempty = CompleteBinaryTree.new(store: @array)
    end

    it "must have a size" do
      @empty.size.must_equal 0
      @nonempty.size.must_equal @array.size
    end

    it "must have a last_idx, nil when empty" do
      @empty.last_idx.nil?.must_equal true
      @nonempty.last_idx.must_equal 99
    end
  end
end
