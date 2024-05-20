require 'rbconfig/sizeof'

# Effortless conversion of bytewise (binary) data
# To and from integers, binary strings, and hex strings

# All binary data is stored internally as an array of integers,
# choosing either 32-bit or 64-bit integers based on platform capability

# Strings, both binary and hex, are represented with least significant byte
# first, so "\xff\x00" is stored as [255], whereas "\x00\xff" is [65280]
# We are using the "packed data" conventions here

# Ruby uses the opposite convention:
#            255 == 0x00ff
#          65280 == 0xff00
#   255.to_s(16) == "ff"
# 65280.to_s(16) == "ff00"

module CompSci
  class BytePack
    # 64-bit systems: 8 bytes;    32-bit systems: 4 bytes
    NATIVE = RbConfig::SIZEOF.fetch('long')

    # return a (BINARY) string, null-padded to a multiple of NATIVE, LSB-first
    def self.prepare(str)
      m = str.bytesize % NATIVE
      m == 0 ? str.b : str.b.ljust(str.length + NATIVE - m, "\x00")
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
    alias_method :ints, :storage

    def initialize(str = nil, hex: nil, int: nil)
      if str
        self.from_s(str)
      elsif hex
        self.from_hex(hex)
      elsif int
        @storage = int.is_a?(Enumerable) ? int : [int]
      else
        @storage = []
      end
    end

    def from_s(str)
      @storage = BytePack.bin2ints(str)
    end

    def to_s
      BytePack.ints2bin(@storage)
    end

    def from_hex(hex_str)
      @storage = BytePack.hex2ints(hex_str)
    end

    def to_hex
      BytePack.ints2hex(@storage)
    end
  end
end
