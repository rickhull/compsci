require 'compsci/bloom_filter'

include CompSci

[9, 99, 999, 9_999, 99_999, 999_999,
 9_999_999, 99_999_999, 999_999_999].each { |items|
  [0.2, 0.1, 0.05, 0.01, 0.001, 0.0001].each { |fpr|
    nb, nh = BloomFilter.optimal(items, fpr: fpr)
    amt, label = BloomFilter.bytes(nb)
    puts format("%i items, FPR: %.4f: %i bits, %.1f %s, %i hashes",
                items, fpr, nb, amt, label, nh)
  }
  puts
}

[8, 10, 16, 20, 30, 32, 40].each { |pow2|
  num_bits = 2**pow2
  amt, label = BloomFilter.bytes(num_bits)
  [5,7,9].each { |num_hashes|
    puts format("%i bits (2^%i) \t %.1f %s \t %i hashes",
                num_bits, pow2, amt, label, num_hashes)
    puts '-' * 20
    puts BloomFilter.analysis(2**pow2, num_hashes)
    puts
  }
}
