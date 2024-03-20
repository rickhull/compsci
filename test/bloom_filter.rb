require 'compsci/bloom_filter'
require 'minitest/autorun'

include CompSci

describe BloomFilter do
  parallelize_me!

  it "has a bitmap for storage" do
    expect(BloomFilter.new.bitmap).must_be_kind_of BitSet
  end

  it "converts strings to a series of bit indices, using modulo(bits)" do
    bf = BloomFilter.new(aspects: 5, bits: 1024)
    bit_indices = bf.index('asdf')
    expect(bit_indices).must_be_kind_of Array
    expect(bit_indices.all? { |i| i >=0 and i < 1024 }).must_equal true
  end

  it "can use a single algorithm to generate multiple indices per string" do
    str = 'qwerty'
    bit_indices = BloomFilter.new.index(str)
    first_bit = bit_indices[0]
    expect(bit_indices.all? { |i| i == first_bit }).wont_equal true
  end

  it "has a false positive rate that increases as it fills up" do
    bf = BloomFilter.new(aspects: 5, bits: 256)
    expect(bf.fpr).must_equal 0

    9.times { |i| bf.add(i.to_s) }
    fpr = bf.fpr
    expect(fpr).must_be :>, 0
    bf.add('asdf')
    expect(bf.fpr).must_be :>, fpr
  end
end
