require 'compsci/bit_set'
require 'minitest/autorun'

include CompSci

describe BitSet do
  parallelize_me!

  it "initializes with the number of bits used for storage" do
    10.times { |i|
      bs = BitSet.new(BitSet::INT_BITS * (i + 1))
      expect(bs.storage.count).must_equal(i + 1)
    }
  end

  it "optionally initializes with all even bits set to 1" do
    stripes = BitSet.new(256, flip_even_bits: true)
    256.times { |i|
      expect(stripes.include? i).must_equal(i % 2 == 0)
    }
  end

  it "can check if bits have been turned on" do
    bs = BitSet.new(64)
    64.times { |i|
      expect(bs.include? i).must_equal false
    }

    jenny = [8, 6, 7, 5, 3, 0, 9].each { |d|
      bs.add d
    }

    64.times { |i|
      expect(bs.include? i).must_equal(jenny.include? i)
    }
  end

  it "can turn the same bit on multiple times without issue" do
    bs = BitSet.new(64)
    expect(bs.include? 1).must_equal false
    bs.add 1
    expect(bs.include? 1).must_equal true
    bs.add 1
    expect(bs.include? 1).must_equal true
    64.times { |i|
      expect(bs.include? i).must_equal(i == 1)
    }
  end

  it "can return an array of bit values" do
    bs = BitSet.new(8, flip_even_bits: true)
    expect(bs.bits.take(8)).must_equal [1, 0, 1, 0, 1, 0, 1, 0]
  end

  it "knows which bit indices are on" do
    bs = BitSet.new(8, flip_even_bits: true)
    expect(bs.on_bits.take(4)).must_equal [0, 2, 4, 6]
  end
end
