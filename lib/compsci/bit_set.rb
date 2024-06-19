require 'rbconfig/sizeof' # stdlib

module CompSci
  # This is basically a bitmap, a data structure to hold some number of bits.
  # It is implemented as an array of integers, giving typically 64 bits
  # per array slot.  The fundamental operations revolve around providing a
  # bit index to either ensure that bit is turned on, or to query its status.
  # Some light arithmetic is needed to address different bits across different
  # array slots.

  class BitSet
    # steep:ignore:start
    INT_BYTES = RbConfig::SIZEOF.fetch('long')    # 64-bit: 8
    INT_BITS = INT_BYTES * 8                      # 32-bit: 4 * 8
    EVEN_BYTE = (2**INT_BITS / 3r).to_i           # 0, 2, 4, etc bits set to 1
    # steep:ignore:end

    # return an array of ones and zeroes, padded to INT_BITS
    def self.bits(int)
      bit_ary = int.digits(2)
      bit_ary + Array.new(INT_BITS - bit_ary.count, 0)
    end

    # kilobytes, megabytes, etc
    KiB = 1024
    MiB = KiB * KiB
    GiB = KiB * MiB
    TiB = KiB * GiB
    PiB = KiB * TiB

    # return a float and a label
    def self.size(bytes: 0, bits: 0)
      bytes += bits.ceildiv(8)
      if bytes < KiB
        [bytes, 'B']
      elsif bytes < MiB
        [bytes.to_f / KiB, 'KiB']
      elsif bytes < GiB
        [bytes.to_f / MiB, 'MiB']
      elsif bytes < TiB
        [bytes.to_f / GiB, 'GiB']
      elsif bytes < PiB
        [bytes.to_f / TiB, 'TiB']
      else
        [bytes.to_f / PiB, 'PiB']
      end
    end

    # storage is an array of integers; count is the number of bits
    attr_reader :storage, :count

    # create an array of integers, default 0; flip_even_bits for testing...
    def initialize(count, flip_even_bits: false)
      # normalize
      div = count.ceildiv(INT_BITS)
      @count = div * INT_BITS
      @storage = Array.new(div, flip_even_bits ? EVEN_BYTE : 0)
      @bits = nil  # used for cache/memoization for the #bits method
    end

    # return an array of ones and zeroes, padded to INT_BITS
    def bits
      @bits ||= @storage.flat_map { |i| self.class.bits(i) }
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
      size, label = self.class.size(bytes: self.byte_count)
      format("%.1f%% positive (%.1f %s)", self.ratio * 100, size, label)
    end
  end
end
