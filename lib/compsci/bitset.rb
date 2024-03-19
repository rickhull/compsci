require 'rbconfig/sizeof'  # stdlib, to determine native int size

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

    attr_reader :storage

    # create an array of integers, default 0
    # use flip_even_bits to initialize with every even bit set to 1
    def initialize(num_bits, flip_even_bits: false)
      init = flip_even_bits ? (2**INT_WIDTH / 3r).to_i : 0
      @storage = [init] * (num_bits / INT_WIDTH.to_f).ceil
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
  end
end
