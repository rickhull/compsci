require 'compsci/bloom_filter'
require 'benchmark/ips'

include CompSci

iters = 999

FILTERS = [
  BloomFilter.new(use_string_hash: false, use_crc32: true), # pure CRC32
  BloomFilter.new(use_string_hash: false, use_crc32: false, # pure Digest
                  use_openssl: false),
  BloomFilter.new(use_string_hash: false, use_crc32: false, # pure OpenSSL
                  use_openssl: true),
  BloomFilter.new(use_string_hash: true, use_crc32: true),  # fast CRC32
  BloomFilter.new(use_string_hash: true, use_crc32: false,  # fast Digest
                  use_openssl: false),
  BloomFilter.new(use_string_hash: true, use_crc32: false,  # fast OpenSSL
                  use_openssl: true),
]

Benchmark.ips do |b|
  b.config(time: 1, warmup: 0.2)

  FILTERS.each { |bf|
    title = format("string:%s\tcrc32:%s\topenssl:%s",
                   bf.use_string_hash,
                   bf.use_crc32,
                   bf.use_crc32 ? 'N/A' : bf.use_openssl)
    b.report(title) {
      iters.times { |i|
        bf.add(i.to_s)
      }
      iters.times { |i|
        bf.include?(rand(iters * 2).to_s)
      }
    }
  }

  b.compare!
end
