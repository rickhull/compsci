require 'compsci/bloom_filter/digest'
require 'openssl' # stdlib

module CompSci
  class BloomFilter
    class OpenSSL < BloomFilter::Digest
      SIZES = {            # in bytes
        "SHA1"      => 20, # (5) 32-bit ints

        "SHA224"    => 28, # (7) 32-bit ints
        "SHA512-224"=> 28, # fastest to slowest
        "SHA3-224"  => 28,

        "SHA256"    => 32, # (8) 32-bit ints
        "BLAKE2s256"=> 32, # fastest to slowest
        "SHA512-256"=> 32,
        "SHA3-256"  => 32,

        "SHA384"    => 48, # (12) 32-bit ints
        "SHA3-384"  => 48, # fastest to slowest

        "BLAKE2b512"=> 64, # (16) 32-bit ints
        "SHA512"    => 64, # fastest to slowest
        "SHA3-512"  => 64,
      }

      def self.new_digest(name)
        ::OpenSSL::Digest.new(name)
      end

      def algo
        "OpenSSL::#{@algo.name}"
      end
    end
  end
end
