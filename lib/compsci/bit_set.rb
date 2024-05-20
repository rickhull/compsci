require 'rbconfig/sizeof' # stdlib

module CompSci
  # This is basically a bitmap, a data structure to hold a large number of
  # bits.  It is implemented as an array of integers, giving typically 64
  # bits per array slot.  The fundamental operations revolve around passing
  # an array of bit indices, like [2, 29, 5874, 13], to either ensure those
  # particular bits are turned on, or to determine whether all those bits
  # are already turned on

  class BitSet
    INT_BYTES = RbConfig::SIZEOF.fetch('long')    # 64-bit: 8
    INT_BITS = INT_BYTES * 8                      # 32-bit: 4 * 8
    EVEN_BYTE = (2**INT_BITS / 3r).to_i           # 0, 2, 4, etc bits set to 1

    # return an array of ones and zeroes, padded to INT_BITS
    def self.bits(int)
      bit_ary = int.digits(2)
      bit_ary + Array.new(INT_BITS - bit_ary.count, 0)
    end

    # kilobytes, megabytes, etc
    KiB = 2**10
    MiB = 2**20
    GiB = 2**30
    TiB = 2**40
    PiB = 2**50

    # return a float and a label
    def self.size(bytes: 0, bits: 0)
      bytes += (bits / 8.0).ceil
      if bytes < KiB
        [bytes, 'B']
      elsif bytes < MiB
        [bytes.to_f / KiB, 'KiB']
      elsif bytes < GiB
        [bytes.to_f / MiB, 'MiB']
      elsif bytes < TiB
        [bytes.to_f / GiB, 'GiB']
      elsif bytes < PiB
        [bytes.to_F / TiB, 'TiB']
      else
        [bytes.to_f / PiB, 'PiB']
      end
    end

    # storage is an array of integers; count is the number of bits
    attr_reader :storage, :count

    # create an array of integers, default 0; flip_even_bits for testing...
    def initialize(count, flip_even_bits: false)
      # normalize
      div = (count / INT_BITS.to_f).ceil
      @count = div * INT_BITS
      @storage = Array.new(div, flip_even_bits ? EVEN_BYTE : 0)
      @bits = nil  # used for cache/memoization for the #bits method
    end

    # return an array of ones and zeroes, padded to INT_BITS
    def bits
      return @bits if @bits
      @bits = @storage.flat_map { |i| self.class.bits(i) }
    end

    # set the bit_index to 1
    def add(bit_index)
      @bits = nil # reset
      slot, val = bit_index.divmod(INT_BITS)
      @storage[slot] |= (1 << val)
    end

    # is the bit_index set to 1?
    def include?(bit_index)
      slot, val = bit_index.divmod(INT_BITS)
      @storage[slot][val] != 0
    end

    # ratio of "on" bits to total bits
    def ratio
      self.bits.count { |b| b == 1 } / @count.to_r
    end

    # return an array of bit indices
    def on_bits
      self.bits.filter_map.with_index { |b, i| i if b == 1 }
    end

    # storage usage in bytes
    def byte_count
      @storage.count * INT_BYTES
    end

    # size, ratio of "on" bits
    def to_s
      format("%.1f%% positive (%.1f %s)",
             self.ratio * 100,
             *self.class.size(bytes: self.byte_count))
    end
  end
end
