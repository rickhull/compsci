require 'compsci/bloom_filter/digest'
require 'openssl' # stdlib

module CompSci
  class BloomFilter
    class OpenSSL < BloomFilter::Digest
      ALGOS = %w[SHA1
                 SHA224 SHA256 SHA384 SHA512
                 SHA512-224 SHA512-256
                 SHA3-224 SHA3-256 SHA3-384 SHA3-512
                 BLAKE2s256 BLAKE2b512].map { |name|
        ::OpenSSL::Digest.new(name)
      }
    end
  end
end
