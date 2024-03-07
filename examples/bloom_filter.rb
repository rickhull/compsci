require 'compsci/bloom_filter'

# conditionally require digest or openssl
required = false
use_string_hash = false

ARGV.each { |arg|
  if arg.match(/openssl/i) and !required
    require 'compsci/bloom_filter/openssl'
    puts "-------"
    puts "OPENSSL"
    puts "-------"
    required = true
  elsif arg.match(/digest/i) and !required
    require 'compsci/bloom_filter/digest'
    puts "------"
    puts "DIGEST"
    puts "------"
    required = true
  elsif arg.match(/use_string_hash/i)
    use_string_hash = true
  end
}

puts "use_string_hash: #{use_string_hash}"

bf = CompSci::BloomFilter.new(use_string_hash: use_string_hash)
puts "Created bloom filter"
puts bf
puts

iters = 9999
iters.times { |i| bf << i.to_s }
puts "Added #{iters} items"
puts bf
puts

found = 0
iters.times {
  found += 1 if bf.include?(rand(iters * 2).to_s)
}
puts "Queried #{iters} items (50% seen), found #{found}"
