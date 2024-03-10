require 'compsci/bloom_filter/digest'
require 'openssl' # stdlib

module CompSci
  class BloomFilter
    class OpenSSL < BloomFilter::Digest
      SIZES = {
        "SHA1"=>20,
        "SHA224"=>28,
        "SHA256"=>32,
        "SHA384"=>48,
        "SHA512"=>64,
        "SHA512-224"=>28,
        "SHA512-256"=>32,
        "SHA3-224"=>28,
        "SHA3-256"=>32,
        "SHA3-384"=>48,
        "SHA3-512"=>64,
        "BLAKE2s256"=>32,
        "BLAKE2b512"=>64,
      }
      DIGESTS = SIZES.keys.map { |name| ::OpenSSL::Digest.new(name) }
    end
  end
end
