require 'openssl' # stdlib

module CompSci
  class BloomFilter
    DIGESTS = %w[SHA1
                 SHA224 SHA256 SHA384 SHA512
                 SHA512-224 SHA512-256
                 SHA3-224 SHA3-256 SHA3-384 SHA3-512
                 BLAKE2s256 BLAKE2b512].map { |name|
      OpenSSL::Digest.new(name)
    }

    def self.hash_bits(str, hashes:, bits:)
      raise "#{hashes} hashes" if hashes > DIGESTS.count
      Array.new(hashes) { |i|
        # only consider the LSB 32-bit integer for modulo
        DIGESTS[i].digest(str).unpack('N*').last % bits
      }
    end
  end
end
