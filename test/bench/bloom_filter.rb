require 'compsci/bloom_filter/openssl'
require 'benchmark/ips' # gem

include CompSci

iters = 999

Benchmark.ips do |b|
  b.config(time: 2, warmup: 0.5)

  [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
    [3, 5, 7, 9, 11].each { |aspect|
      b.report("#{klass} (#{aspect} aspects)") {
        [8, 10, 16, 24].each { |bitpow|
          bf = klass.new(bits: 2**bitpow, aspects: aspect)
          iters.times { |i| bf.add(i.to_s) }
          iters.times {     bf.include?(rand(iters * 2).to_s) }
        }
      }
    }
  }

  b.compare!
end
