require 'compsci/string_pack'
require 'rbconfig/sizeof'

# Effortless conversion of bytewise (binary) data
# To and from integers, binary strings, hexadecimal and base64 strings

# refinement to add String#pack
using StringPack

module CompSci
  class BytePack
    NATIVE = RbConfig::SIZEOF.fetch('long') # 64-bit: 8   32-bit: 4
    INTMAX = 2 ** (NATIVE * 8) - 1

    VAL = "\xFF\x00\x00\x00".b
    ENDIAN = VAL.unpack('N*') == VAL.unpack('L*') ? :big : :little

    # format hex with rows and cols
    def self.format(hex)
      cursor, step = 0, 8
      chunks = []
      while cursor < hex.bytesize
        chunks << hex.slice(cursor, step)
        cursor += step
      end

      cursor, step = 0, 2
      combos = []
      while cursor < chunks.count
        combos << chunks.slice(cursor, 2).join(" ")
        cursor += 2
      end

      cursor, step = 0, 4
      lines = []
      while cursor < combos.count
        lines << combos.slice(cursor, step).join("  ").upcase
        cursor += step
      end

      lines.join($/)
    end

    # generate a new BytePack using random integers
    def self.random(length)
      self.new(int: Array.new(length.ceildiv NATIVE) { rand INTMAX })
    end

    # return a (BINARY) string, null-padded to a multiple of width
    def self.prepare(str, width: NATIVE, endian: ENDIAN)
      str = str.b
      m = str.length % width
      return str if m == 0
      w = str.length + width - m
      endian == :little ? str.ljust(w, "\x00") : str.rjust(w, "\x00")
    end

    # array of 32b integers, network byte order
    def self.bin2net(str)
      self.prepare(str, width: 4, endian: :big).unpack('N*')
    end

    # encoding: BINARY, network byte order
    def self.net2bin(ints)
      ints.pack('N*')
    end

    # array of integers, native width and endianness
    def self.bin2ints(str)
      self.prepare(str).unpack('J*')
    end

    # encoding: BINARY, native width and endianness
    def self.ints2bin(ints)
      ints.pack('J*')
    end

    # encoding: US-ASCII, lowercase hex
    def self.bin2hex(str)
      str.unpack1('H*')
    end

    # encoding: BINARY
    def self.hex2bin(hex_str)
      hex_str.pack('H*')
    end

    # encoding: US-ASCII, base64, no trailing newline
    def self.bin2b64(str)
      str.pack('m0')
    end

    # encoding: BINARY
    def self.b642bin(b64_str)
      b64_str.unpack1('m0')
    end

    # fundamentally, this is a String, encoding: BINARY
    attr_reader :storage
    alias_method :binary, :storage

    def initialize(str = nil, hex: nil, net: nil, int: nil, base64: nil)
      @storage = if str
                   str.b
                 elsif net
                   BytePack.net2bin(net.is_a?(Array) ? net : [net])
                 elsif int
                   BytePack.ints2bin(int.is_a?(Array) ? int : [int])
                 elsif hex
                   BytePack.hex2bin(hex)
                 elsif base64
                   BytePack.b642bin(base64)
                 else
                   "".b
                 end
    end

    # 32-bit integers, network byte order
    def net
      BytePack.bin2net(@storage)
    end

    # address the network integers
    def [](idx)
      self.net[idx]
    end

    # up to 64-bit integers, native byte order
    def ints
      BytePack.bin2ints(@storage)
    end

    # calculate a giant integer from native integers, may be slow
    def bignum
      i = -1
      self.ints.inject(0) { |memo, int|
        i += 1
        memo + int * (INTMAX+1) ** i
      }
    end

    # calculate a giant integer from network integers, may be slow
    def bignet
      #i = -1
      #self.net.reverse.inject(0) { |memo, int|
      #  i += 1
      #  memo + int * (2**32) ** i
      #}
      self.hex.to_i(16)   # 10x faster than above
    end

    # lowercase hex, encoding: US-ASCII
    def hex
      BytePack.bin2hex(@storage)
    end
    alias_method :inspect, :hex
    alias_method :to_s, :hex

    # encoding: US-ASCII
    def base64
      BytePack.bin2b64(@storage)
    end

    # formatted with rows and cols
    def hexdump
      BytePack.format(self.hex)
    end
  end
end
