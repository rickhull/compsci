require 'zlib'   # stdlib
require 'bitset' # gem

module CompSci
  class BloomFilter
    MAX_BITS = 2**32 # CRC32 yields 32-bit values

    attr_reader :bits, :aspects, :bitmap

    # The default values require 8 kilobytes of storage and recognize:
    # < 7000 strings at 1% False Positive Rate (4k @ 0.1%) (10k @ 5%)
    # FPR goes up as more strings are added
    def initialize(bits: 2**16, aspects: 5)
      @bits = bits
      raise("bits: #{@bits}") if @bits > MAX_BITS
      @aspects = aspects
      @bitmap = Bitset.new(@bits)
    end

    # Return an array of bit indices ("on bits") corresponding to
    # multiple rounds of string hashing (CRC32 is fast and ~fine~)
    def index(str)
      val = 0
      Array.new(@aspects) { (val = Zlib.crc32(str, val)) % @bits }
    end

    def add(str)
      @bitmap.set(*self.index(str))
    end
    alias_method(:<<, :add)

    # true or false; a `true` result mayb be a "false positive"
    def include?(str)
      @bitmap.set?(*self.index(str))
    end

    # returns either 0 or a number like 0.95036573
    def likelihood(str)
      self.include?(str) ? 1.0 - self.fpr : 0
    end
    alias_method(:[], :likelihood)

    # relatively expensive; don't test against this in a loop
    def percent_full
      @bitmap.to_a.count.to_f / @bits
    end

    def fpr
      self.percent_full**@aspects
    end

    def algo
      'CRC32'
    end

    def to_s
      format("%i bits (%.1f kB, %i aspects %s) %i%% full; FPR: %.3f%%",
             @bits, @bits.to_f / 2**13, @aspects, self.algo,
             self.percent_full * 100, self.fpr * 100)
    end
    alias_method(:inspect, :to_s)
  end
end
