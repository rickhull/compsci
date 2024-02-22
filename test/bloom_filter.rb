require 'compsci/bloom_filter'
require 'minitest/autorun'

include CompSci

describe BloomFilter do
  it "has a bitmap for storage" do
    expect(BloomFilter.new.bitmap).must_be_kind_of Bitset
  end

  it "hashes strings to determine which bits to turn on, by using" +
     "modulo to map a giant hash value to a bit index" do
    bit_indices = BloomFilter.hash_bits('asdf', num_hashes: 5, num_bits: 1024)
    expect(bit_indices).must_be_kind_of Array
    expect(bit_indices.all? { |i| i >=0 and i < 1024 }).must_equal true
  end

  it "performs multiple rounds of hashing that yield different bit indices " +
     "for the same string" do
    str = 'asdf'
    bit_indices = BloomFilter.hash_bits(str, num_hashes: 5, num_bits: 1024)
    first_bit = bit_indices[0]
    expect(bit_indices.all? { |i| i == first_bit }).wont_equal true
  end

  it "has a false positive rate that increases as it fills up" do
    bf = BloomFilter.new(num_hashes: 5, num_bits: 256)
    expect(bf.fpr).must_equal 0

    9.times { |i| bf.add(i.to_s) }
    fpr = bf.fpr
    expect(fpr).must_be :>, 0
    bf.add('asdf')
    expect(bf.fpr).must_be :>, fpr
  end
end
