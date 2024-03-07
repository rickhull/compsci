require 'zlib'   # stdlib
require 'bitset' # gem

module CompSci
  class BloomFilter
    # Return an array of bit indices ("on bits") corresponding to
    # multiple rounds of string hashing
    # CRC32 is not true hashing but it should be random and uniform
    # enough for our purposes, as well as being quite fast
    def self.hash_bits(str, num_hashes:, num_bits:)
      val = 0
      Array.new(num_hashes) {
        (val = Zlib.crc32(str, val)) % num_bits
      }
    end

    attr_reader :num_bits, :num_hashes, :bitmap, :use_string_hash

    # The default values require 8 kilobytes of storage and recognize:
    # < 4000 strings; FPR 0.1%
    # < 7000 strings; FPR 1%
    # >  10k strings; FPR 5%
    # The false positive rate goes up as more strings are added
    def initialize(num_bits: 2**16, num_hashes: 5, use_string_hash: true)
      @num_bits = num_bits
      @num_hashes = num_hashes
      @bitmap = Bitset.new(@num_bits)
      @use_string_hash = use_string_hash
    end

    def hash_bits(str)
      if @use_string_hash
        BloomFilter.hash_bits(str,
                              num_hashes: @num_hashes - 1,
                              num_bits: @num_bits).push(str.hash % @num_bits)
      else
        BloomFilter.hash_bits(str,
                              num_hashes: @num_hashes,
                              num_bits: @num_bits)
      end
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
      @bitmap.to_a.count.to_f / @num_bits
    end

    def fpr
      self.percent_full**@num_hashes
    end

    def estimated_items
      require 'compsci/bloom_filter/theory'
      BloomFilter.num_items(@num_bits, @num_hashes, @bitmap.to_a.count)
    end

    def to_s
      format("%i bits (%.1f kB, %i hashes) %i%% full; FPR: %.3f%%",
             @num_bits, @num_bits.to_f / 2**13, @num_hashes,
             self.percent_full * 100, self.fpr * 100)
    end
    alias_method(:inspect, :to_s)
  end
end
