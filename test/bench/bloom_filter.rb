require 'compsci/bloom_filter/openssl'
require 'benchmark/ips' # gem

include CompSci

iters = 999
bits = 2**16
hashes = 6

Benchmark.ips do |b|
  b.config(time: 2, warmup: 0.2)

  [true, false].each { |use_string_hash|
    [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
      b.report("#{klass} (use_string_hash: #{use_string_hash})") {
        args = { use_string_hash: use_string_hash,
                 bits: bits,
                 hashes: hashes, }
        bf = klass.new(**args)
        iters.times { |i| bf.add(i.to_s) }
        iters.times {     bf.include?(rand(iters * 2).to_s) }
      }
    }
  }

  b.compare!
end
