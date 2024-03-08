require 'compsci/bloom_filter/openssl'

include CompSci

# simulate a db query that returns true for roughly 10% of queries
# a true result means additional (hypothetical) processing is required
def db_query(num, mod: 10, elapsed: 0.01)
  sleep elapsed
  num % mod == 0
end

# check ARGV for config directives
use_string_hash = false
klass = BloomFilter
ARGV.each { |arg|
  if arg.match(/digest/i)
    klass = BloomFilter::Digest
  elsif arg.match(/openssl/i)
    klass = BloomFilter::OpenSSL
  elsif arg.match(/use_string_hash/i)
    use_string_hash = true
  end
}

bf = klass.new(use_string_hash: use_string_hash)
puts format("%s.new(use_string_hash: %s)", klass.name, use_string_hash)
puts bf
puts

# now we want to preload the filter to match the db
# if the db returns true, we will take hypothetical further action
# if the db returns false, no action necessary
# so we want to load the filter with queries for which the db will return true
# if the filter returns true, we still check the db
# the db will probably return true but maybe false (BF false positive)
# if the filter returns false, we're done

iters = 999
iters.times { |i|
  bf.add(i.to_s) if db_query(i, mod: 10, elapsed: 0)
}
puts "Ran #{iters} queries to load the filter"
puts bf
puts

#################

puts "Running queries straight to db..."
t = Time.new
counts = { true => 0, false => 0 }
iters = 99
iters.times { |i|
  counts[db_query(i)] += 1
}
elapsed = Time.new - t
puts format("Ran %i queries straight to db; %.2f s elapsed", iters, elapsed)
puts counts
puts

#################

puts "Running queries filtered by bloom filter..."
t = Time.new
counts = { true => 0, false => 0 }
iters = 99
iters.times { |i|
  if bf.include?(i.to_s)
    counts[db_query(i)] += 1
  else
    counts[false] += 1
  end
}
elapsed = Time.new - t
puts format("Ran %i filtered queries; %.2f s elapsed", iters, elapsed)
puts counts
puts
