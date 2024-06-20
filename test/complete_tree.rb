require 'compsci/complete_tree'
require 'minitest/autorun'

include CompSci

describe CompleteTree do
  parallelize_me!

  it "must calculate a parent index for N=2" do
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
      expect(CompleteTree.parent_idx(idx, 2)).must_equal pidx
    }
    invalid.each { |idx, pidx|
      expect(CompleteTree.parent_idx(idx, 2)).must_equal pidx
    }
  end

  it "must calculate children indices for N=2" do
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
      expect(CompleteTree.children_idx(idx, 2)).must_equal cidx
    }
    invalid.each { |idx, cidx|
      expect(CompleteTree.children_idx(idx, 2)).must_equal cidx
    }
  end

  it "must calculate a parent index for N=3" do
    valid = {
      1 => 0,
      2 => 0,
      3 => 0,
      4 => 1,
      5 => 1,
      6 => 1,
      7 => 2,
      8 => 2,
      9 => 2,
      10 => 3,
    }

    invalid = {
      0 => -1,
      -1 => -1,
      -2 => -1,
    }
    valid.each { |idx, pidx|
      expect(CompleteTree.parent_idx(idx, 3)).must_equal pidx
    }
    invalid.each { |idx, pidx|
      expect(CompleteTree.parent_idx(idx, 3)).must_equal pidx
    }
  end

  it "must calculate children indices for N=3" do
    valid = {
      0 => [1, 2, 3],
      1 => [4, 5, 6],
      2 => [7, 8, 9],
      3 => [10, 11, 12],
    }

    invalid = {
      -3 => [-8, -7, -6],
      -2 => [-5, -4, -3],
      -1 => [-2, -1,  0],
    }

    valid.each { |idx, cidx|
      expect(CompleteTree.children_idx(idx, 3)).must_equal cidx
    }
    invalid.each { |idx, cidx|
      expect(CompleteTree.children_idx(idx, 3)).must_equal cidx
    }
  end

  describe "instance" do
    parallelize_me!

    before do
      @array = (0..99).sort_by { rand }
      @empty = CompleteTree.new(child_slots: 5)
      @nonempty = CompleteTree.new(array: @array, child_slots: 4)
    end

    it "must have a size" do
      expect(@empty.size).must_equal 0
      expect(@nonempty.size).must_equal @array.size
    end
  end
end
