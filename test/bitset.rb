require 'compsci/bitset'
require 'minitest/autorun'

include CompSci

describe BitSet do
  it "initializes with the number of bits used for storage" do
    10.times { |i|
      bs = BitSet.new(BitSet::INT_WIDTH * (i + 1))
      expect(bs.storage.count).must_equal(i + 1)
    }
  end

  it "optionally initializes with all even bits set to 1" do
    stripes = BitSet.new(256, flip_even_bits: true)
    256.times { |i|
      expect(stripes.set? [i]).must_equal(i % 2 == 0)
    }
  end

  it "can check if bits have been turned on" do
    bs = BitSet.new(64)
    64.times { |i|
      expect(bs.set? [i]).must_equal false
    }

    jenny = [8, 6, 7, 5, 3, 0, 9]

    bs.set jenny

    64.times { |i|
      expect(bs.set? [i]).must_equal(jenny.include? i)
    }
  end

  it "can turn the same bit on multiple times without issue" do
    bs = BitSet.new(64)
    expect(bs.set? [1]).must_equal false
    bs.set [1]
    expect(bs.set? [1]).must_equal true
    bs.set [1, 1]
    expect(bs.set? [1]).must_equal true
    64.times { |i|
      expect(bs.set? [i]).must_equal(i == 1)
    }
  end
end
