require 'compsci/bloom_filter'
require 'digest'  # stdlib

module CompSci
  class BloomFilter
    class Digest < BloomFilter
      ALGOS = %w[MD5 SHA1 SHA256 SHA384 SHA512 RMD160].map { |name|
        Digest(name).new
      }

      def self.hash_bits(str, hashes:, bits:)
        raise "Too many: #{hashes} hashes" if hashes > self::ALGOS.count
        Array.new(hashes) { |i|
          self::ALGOS[i].digest(str).unpack('N*').last % bits
        }
      end
    end
  end
end
