require 'compsci/bloom_filter'
require 'digest'  # stdlib

module CompSci
  class BloomFilter
    # this class will be inherited from, so it uses a lot of `self::`
    class Digest < BloomFilter
      SIZES = {         # in bytes
        "MD5"    => 16, # (4) 32-bit ints
        "RMD160" => 20, # (5) 32-bit ints
        "SHA1"   => 20, # not as fast as RIPEMD
        "SHA256" => 32, # (8) 32-bit ints
        "SHA384" => 48, # (12) 32-bit ints
        "SHA512" => 64, # (16) 32-bit ints
      }

      def self.algos(aspects)
        self::SIZES.select { |_, bytes| aspects * 4 <= bytes }.keys
      end

      def self.valid?(algo, aspects)
        aspects <= (self::SIZES.fetch(algo) / 4.0).floor
      end

      def self.new_digest(name)
        Digest(name).new
      end

      def initialize(bits: 2**16, aspects: 5, algo: nil)
        @bits = bits
        @aspects = aspects
        @bitmap = Bitset.new(@bits)
        if algo
          unless self.class.valid?(algo, @aspects)
            raise "#{algo} is too small for #{@aspects} aspects"
          end
        else
          algo = self.class.algos(@aspects).first
        end
        @algo = self.class.new_digest(algo)
      end

      # operate on 4-byte chunks of the hash value to yield 32 bit integers
      def hash_bits(str)
        @algo.digest(str).unpack('N*').last(@aspects).map { |i| i % @bits }
      end

      def algo
        @algo.class.to_s
      end
    end
  end
end
