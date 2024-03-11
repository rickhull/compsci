require 'compsci/bloom_filter/openssl'
require 'compsci/names/pokemon'

include CompSci

# should yield 50% full at 7 aspects
sizing = {
  12 => 500,
  14 => 2000,
  16 => 8000,
  18 => 32000,
}

[4, 5, 7, 9, 11].each { |aspect|
  puts "Aspects: #{aspect}"
  puts "-------"

  sizing.each { |bitpow, items|
    # relative to 7 aspects, more aspects means less items
    items = (items * 7.0 / aspect).round

    [BloomFilter, BloomFilter::Digest, BloomFilter::OpenSSL].each { |klass|
      loops = 0
      count = 0

      bf = klass.new(bits: 2**bitpow, aspects: aspect)
      while count < items
        CompSci::Names::Pokemon.array.each { |name|
          break if count >= items
          bf << "#{name}#{loops}"
          count += 1
        }
        loops += 1
      end

      puts bf
      puts "items: #{count}"
      puts "loops: #{loops}"
      puts
    }
  }
  puts
}
