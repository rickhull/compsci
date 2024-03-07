require 'zlib'   # stdlib
require 'bitset' # gem

module CompSci
  class BloomFilter
    # Return an array of bit indices ("on bits") corresponding to
    # multiple rounds of string hashing (CRC32 is fast and ~fine~)
    def self.hash_bits(str, hashes:, bits:)
      val = 0
      Array.new(hashes) { (val = Zlib.crc32(str, val)) % bits }
    end

    attr_reader :bits, :hashes, :bitmap, :use_string_hash

    # The default values require 8 kilobytes of storage and recognize:
    # < 7000 strings at 1% False Positive Rate (4k @ 0.1%) (10k @ 5%)
    # FPR goes up as more strings are added
    def initialize(bits: 2**16, hashes: 5, use_string_hash: true)
      @bits = bits
      @hashes = hashes
      @bitmap = Bitset.new(@bits)
      @use_string_hash = use_string_hash
    end

    def hash_bits(str)
      @use_string_hash ?
        BloomFilter.hash_bits(str, hashes: @hashes - 1, bits: @bits).
          push(str.hash % @bits) :
        BloomFilter.hash_bits(str, hashes: @hashes, bits: @bits)
    end

    def add(str)
      @bitmap.set(*self.hash_bits(str))
    end
    alias_method(:<<, :add)

    def include?(str)
      @bitmap.set?(*self.hash_bits(str))
    end

    def likelihood(str)
      self.include?(str) ? 1.0 - self.fpr : 0
    end
    alias_method(:[], :likelihood)

    def percent_full
      @bitmap.to_a.count.to_f / @bits
    end

    def fpr
      self.percent_full**@hashes
    end

    def to_s
      format("%i bits (%.1f kB, %i hashes) %i%% full; FPR: %.3f%%",
             @bits, @bits.to_f / 2**13, @hashes,
             self.percent_full * 100, self.fpr * 100)
    end
    alias_method(:inspect, :to_s)
  end
end
