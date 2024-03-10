require 'compsci/bloom_filter/openssl'
require 'benchmark/ips' # gem

include CompSci

iters = 499

Benchmark.ips do |b|
  b.config(time: 2, warmup: 0.5)

  [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
    b.report("#{klass}") {
      bitpow = [8, 10, 16, 24]
      aspects = [3, 5, 7, 9, 11]

      bitpow.each { |p|
        aspects.each { |a|
          bf = klass.new(bits: 2**p, aspects: a)
          iters.times { |i| bf.add(i.to_s) }
          iters.times {     bf.include?(rand(iters * 2).to_s) }
        }
      }
    }
  }

  b.compare!
end
