require 'digest'  # stdlib

module CompSci
  class BloomFilter
    DIGESTS = %w[MD5 SHA1 SHA256 SHA384 SHA512 RMD160].map { |name|
      Digest(name).new
    }

    def self.hash_bits(str, num_hashes:, num_bits:)
      raise "#{num_hashes} hashes" if num_hashes > DIGESTS.count
      Array.new(num_hashes) { |i|
        DIGESTS[i].digest(str).unpack('N*').last % num_bits
      }
    end
  end
end
