require 'compsci/bloom_filter/theory'
require 'compsci/bloom_filter/openssl'

include CompSci

def ingest(filter, items)
  items.times { |i| filter.add(i.to_s) }
end

[9, 99, 999, 9_999, 99_999, 999_999,
 9_999_999, 99_999_999, 999_999_999].each { |items|
  [0.2, 0.1, 0.05, 0.01, 0.001, 0.0001].each { |fpr|
    nb, nh = BloomFilter.optimal(items: items, fpr: fpr)
    amt, label = BitSet.size(bits: nb)
    puts format("%i items, FPR: %.4f: %i bits, %.1f %s, %i aspects",
                items, fpr, nb, amt, label, nh)
  }
  puts
}

[8, 10, 12, 16, 18, 20, 30, 32, 40].each { |pow2|
  bits = 2**pow2
  amt, label = BitSet.size(bits: bits)
  [5,7,9].each { |aspects|
    puts format("%i bits (2^%i) \t %.1f %s \t %i aspects",
                bits, pow2, amt, label, aspects)
    puts '-' * 20
    puts BloomFilter.analysis(bits: 2**pow2, hashes: aspects)
    puts
  }
}

POW = [10, 16, 20]
ASPECTS = [4, 8, 12]

unless ARGV.grep(/predict/i).empty?
  POW.each { |pow2|
    bits = 2**pow2
    puts "Bits: 2^#{pow2} (#{bits})"
    puts
    ASPECTS.each { |aspects|
      puts "Aspects: #{aspects}"
      puts
      [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
        bf = klass.new(bits: bits, aspects: aspects)
        puts bf
        count = 0
        BloomFilter.analyze(bits: bits,
                            hashes: aspects).each { |(pct, items, fpr)|
          while count < items
            bf << count.to_s
            count += 1
          end
          puts "Ingested #{count} items"
          puts format("%.3f%% full\t(%.3f%% predicted)",
                      bf.percent_full * 100, pct * 100)
          puts format("%.3f%% FPR \t(%.3f%% predicted)",
                      bf.fpr, fpr)
          puts
        }
        puts
      }
      puts
    }
    puts
  }
end
