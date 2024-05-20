require 'rbconfig/sizeof'

# Effortless conversion of bytewise (binary) data
# To and from integers, binary strings, and hex strings

module CompSci
  class BytePack
    NATIVE = RbConfig::SIZEOF.fetch('long') # 64-bit: 8   32-bit: 4
    VAL = "\xFF\x00\x00\x00"
    ENDIAN = VAL.unpack('N*') == VAL.unpack('L*') ? :big : :little

    # return a (BINARY) string, null-padded to a multiple of NATIVE
    def self.prepare(str)
      str = str.b
      m = str.length % NATIVE
      return str if m == 0
      width = str.length + NATIVE - m
      ENDIAN == :little ? str.ljust(width, "\00") : str.rjust(width, "\x00")
    end

    def self.hex2bin(hex_str)
      [hex_str].pack('H*')             # encoding: BINARY
    end

    def self.bin2hex(str)
      str.unpack1('H*')                # encoding: US-ASCII
    end

    def self.ints2bin(ints)
      ints.pack('J*')                  # encoding: BINARY
    end

    def self.bin2ints(str)
      self.prepare(str).unpack('J*')
    end

    # hex -> binary -> ints
    def self.hex2ints(hex_str)
      self.bin2ints(self.hex2bin(hex_str))
    end

    # ints -> binary -> hex
    def self.ints2hex(ints)
      self.bin2hex(self.ints2bin(ints)) # encoding: US-ASCII
    end

    attr_reader :storage

    def initialize(str = nil, hex: nil, int: nil)
      @storage = if str
                   str
                 elsif hex
                   BytePack.hex2bin(hex)
                 elsif int
                   BytePack.ints2bin(int.is_a?(Enumerable) ? int : [int])
                 else
                   "".b
                 end
    end

    def to_s
      @storage
    end

    def hex
      BytePack.bin2hex(@storage)
    end
    alias_method :inspect, :hex

    def ints
      BytePack.bin2ints(@storage)
    end

    def [](idx)
      self.ints[idx]
    end
  end
end
