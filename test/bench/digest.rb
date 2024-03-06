# require 'compsci/bloom_filter'
require 'zlib'
require 'digest'
require 'openssl'
require 'benchmark/ips'

DIGESTS = %w[MD5 SHA1 SHA256 SHA384 SHA512 RMD160].map { |name|
  Digest(name).new
}

OPENSSL_DIGESTS = %w[SHA1
                     SHA224 SHA256 SHA384 SHA512
                     SHA512-224 SHA512-256
                     SHA3-224 SHA3-256 SHA3-384 SHA3-512
                     BLAKE2s256 BLAKE2b512].map { |name|
  OpenSSL::Digest.new(name)
}

# so much faster, it throws off the comparison
INCLUDE_CRC32 = false

str = 'All work and no play makes Jack a very dull boy.'

Benchmark.ips do |b|
  b.config(time: 1, warmup: 0.2)

  if INCLUDE_CRC32
    b.report("Zlib.crc32") {
      Zlib.crc32(str)
    }
  end

  DIGESTS.each { |algo|
    b.report(algo.class.to_s) {
      algo.digest(str)
    }
  }

  OPENSSL_DIGESTS.each { |algo|
    b.report("OpenSSL::Digest(#{algo.name})") {
      algo.digest(str)
    }
  }

  b.compare!
end
