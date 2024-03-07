require 'digest'  # stdlib

module CompSci
  class BloomFilter
    DIGESTS = %w[MD5 SHA1 SHA256 SHA384 SHA512 RMD160].map { |name|
      Digest(name).new
    }

    def self.hash_bits(str, hashes:, bits:)
      raise "Too many: #{hashes} hashes" if hashes > DIGESTS.count
      Array.new(hashes) { |i|
        DIGESTS[i].digest(str).unpack('N*').last % bits
      }
    end
  end
end
