require 'compsci/bloom_filter'
# conditionally require digest or openssl
ARGV.each { |arg|
  if arg.match /openssl/i
    require 'compsci/bloom_filter/openssl'
    puts "-------"
    puts "OPENSSL"
    puts "-------"
    break
  elsif arg.match /digest/i
    require 'compsci/bloom_filter/digest'
    puts "------"
    puts "DIGEST"
    puts "------"
    break
  end
}

require 'benchmark/ips' # gem

include CompSci

iters = 1999
num_bits = 2**16
num_hashes = 6

Benchmark.ips do |b|
  b.config(time: 2, warmup: 0.2)

  [true, false].each { |use_string_hash|
    b.report("use_string_hash: #{use_string_hash}") {
      bf = BloomFilter.new(use_string_hash: use_string_hash,
                           num_bits: num_bits,
                           num_hashes: num_hashes)
      iters.times { |i| bf.add(i.to_s) }
      iters.times {     bf.include?(rand(iters * 2).to_s) }
    }
  }

  b.compare!
end
