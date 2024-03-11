require 'compsci/bloom_filter/openssl'
require 'benchmark/ips' # gem

include CompSci

items = 999

Benchmark.ips do |b|
  b.config(time: 2, warmup: 0.5)

  [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
    [3, 5, 7, 9, 11].each { |aspect|
      b.report("#{klass} (#{aspect} aspects)") {
        [8, 10, 16, 24].each { |bitpow|
          bf = klass.new(bits: 2**bitpow, aspects: aspect)
          # run ingestion once
          items.times { |i| bf.add(i.to_s) }

          # run 10x the number queries
          # we've doubled the item space so expect 50% hit rate
          (items * 10).times { bf.include?(rand(items * 2).to_s) }
        }
      }
    }
  }

  b.compare!
end
