require 'compsci/tree'
require 'minitest/autorun'

include CompSci

describe Tree do
  it "must stuff" do
    true.must_equal true
  end

  describe Tree::Node do
    it "must stuff" do
      true.must_equal true
    end
  end
end

describe BinaryTree do
  it "must stuff" do
    true.must_equal true
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
