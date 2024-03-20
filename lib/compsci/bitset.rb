require 'rbconfig/sizeof'  # stdlib, to determine native int size
# require 'fiddle'  # requires ruby to be built against libffi

module CompSci
  # This is basically a bitmap, a data structure to hold a large number of
  # bits.  It is implemented as an array of integers, giving typically 64
  # bits per array slot.  The fundamental operations revolve around passing
  # an array of bit indices, like [2, 29, 5874, 13], to either ensure those
  # particular bits are turned on, or to determine whether all those bits
  # are already turned on

  class BitSet
    # in bits, e.g. 64 bit / 32 bit platforms.  SIZEOF returns byte width
    INT_WIDTH = RbConfig::SIZEOF.fetch('long') * 8
    # INT_WIDTH = Fiddle::SIZEOF_LONG * 8

    # return an array of ones and zeroes, padded to INT_WIDTH
    def self.bits(int)
      bit_ary = int.digits(2)
      bit_ary + Array.new(INT_WIDTH - bit_ary.count, 0)
    end

    attr_reader :storage

    # create an array of integers, default 0
    # use flip_even_bits to initialize with every even bit set to 1
    def initialize(num_bits, flip_even_bits: false)
      init = flip_even_bits ? (2**INT_WIDTH / 3r).to_i : 0
      @storage = Array.new((num_bits / INT_WIDTH.to_f).ceil, init)
    end

    # ensure the given bit_indices are set to 1
    def set(bit_indices)
      bit_indices.each { |b|
        slot, val = b.divmod(INT_WIDTH)
        @storage[slot] |= (1 << val)
      }
    end

    # determine if all given bit indices are set to 1
    def set?(bit_indices)
      bit_indices.all? { |b|
        slot, val = b.divmod(INT_WIDTH)
        @storage[slot][val] != 0
      }
    end

    # returns an array of ones and zeroes, padded to INT_WIDTH
    def bits
      @storage.flat_map { |i| self.class.bits(i) }
    end

    # returns an array of bit indices
    def on_bits
      self.bits.filter_map.with_index { |b, i| i if b == 1 }
    end
  end
end
