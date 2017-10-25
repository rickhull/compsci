require 'compsci/tree'
require 'minitest/autorun'

include CompSci

describe Tree do
  before do
    @node = Tree::Node.new 42
    @tree = Tree.new(@node, child_slots: 3)
  end

  it "must have an open parent" do
    @tree.open_parent?(@node).must_equal true
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
      @tree = Tree.new(Tree::Node.new 42)
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

  describe Tree::Node do
    before do
      @martin_sheen = Tree::Node.new 'martin'
      @charlie_sheen = Tree::Node.new 'charlie'
      @emilio_estevez = Tree::Node.new 'emilio'
    end

    it "must start with no relations" do
      [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
        n.parent.nil?.must_equal true
        n.children.must_be_empty
      }
    end

    it "must allow relations" do
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
end

describe BinaryTree do
  before do
    @tree = BinaryTree.new(Tree::Node.new 42)
  end

  it "must have 2 child_slots" do
    @tree.child_slots.must_equal 2
  end

  it "must bf_print" do
    31.times { @tree.push rand 99 }
    out, err = capture_io do
      @tree.bf_print
    end
    line_count = out.split("\n").size
    line_count.must_be :>, 4
    line_count.must_be :<, 7
    err.must_be_empty
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
