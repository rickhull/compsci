require 'rbconfig/sizeof'  # stdlib, also consider: fiddle

module CompSci
  # This is basically a bitmap, a data structure to hold a large number of
  # bits.  It is implemented as an array of integers, giving typically 64
  # bits per array slot.  The fundamental operations revolve around passing
  # an array of bit indices, like [2, 29, 5874, 13], to either ensure those
  # particular bits are turned on, or to determine whether all those bits
  # are already turned on

  class BitSet
    # in bits, e.g. 64 bit / 32 bit platforms.  SIZEOF returns byte width
    INT_WIDTH = RbConfig::SIZEOF.fetch('long') * 8 # Fiddle::SIZEOF_LONG * 8
    EVEN_BYTE = (2**INT_WIDTH / 3r).to_i           # even bits turned on

    # return an array of ones and zeroes, padded to INT_WIDTH
    def self.bits(int)
      bit_ary = int.digits(2)
      bit_ary + Array.new(INT_WIDTH - bit_ary.count, 0)
    end

    attr_reader :storage

    # create an array of integers, default 0
    # use flip_even_bits to initialize with every even bit set to 1
    def initialize(num_bits, flip_even_bits: false)
      @storage = Array.new((num_bits / INT_WIDTH.to_f).ceil,
                           flip_even_bits ? EVEN_BYTE : 0)
    end

    # set the bit_index to 1
    def add(bit_index)
      slot, val = bit_index.divmod(INT_WIDTH)
      @storage[slot] |= (1 << val)
    end

    # is the bit_index set to 1?
    def include?(bit_index)
      slot, val = bit_index.divmod(INT_WIDTH)
      @storage[slot][val] != 0
    end

    # return an array of ones and zeroes, padded to INT_WIDTH
    def bits
      @storage.flat_map { |i| self.class.bits(i) }
    end

    # return an array of bit indices
    def on_bits
      self.bits.filter_map.with_index { |b, i| i if b == 1 }
    end
  end
end
