require 'compsci/bloom_filter'
require 'digest'  # stdlib

module CompSci
  class BloomFilter
    class Digest < BloomFilter
      SIZES = {
        "MD5"=>16,
        "RMD160"=>20,
        "SHA1"=>20,
        "SHA256"=>32,
        "SHA384"=>48,
        "SHA512"=>64,
      }
      DIGESTS = SIZES.keys.map { |name| Digest(name).new }

      def self.hash_bits(str, hashes:, bits:)
        raise "Too many: #{hashes} hashes" if hashes > self::DIGESTS.count
        Array.new(hashes) { |i|
          self::DIGESTS[i].digest(str).unpack('N*').last % bits
        }
      end
    end
  end
end
