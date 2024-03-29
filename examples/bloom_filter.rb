require 'compsci/bloom_filter/openssl'

include CompSci

# simulate a db query that returns data for roughly 10% of queries
# a non-nil result means additional (hypothetical) processing is required
def db_query(num, mod: 10, elapsed: 0.01)
  sleep elapsed
  Zlib.crc32(num.to_s) if num % mod == 0
end

# check ARGV for config directives
klass = BloomFilter
ARGV.each { |arg|
  if arg.match(/digest/i)
    klass = BloomFilter::Digest
  elsif arg.match(/openssl/i)
    klass = BloomFilter::OpenSSL
  end
}

bf = klass.new(bits: 1024)
puts klass.name
puts bf
puts

# now we want to preload the filter to match the db
# if the db returns a record, we will take hypothetical further action
# if the db returns nil, no action necessary
# so we want to load the filter with queries for which the db has records
# if the filter returns true, we still check the db
# the db will probably return true but maybe false (BF false positive)
# if the filter returns false, we're done, without checking the db


# first dump all known records into the filter
value_space = 999       # possible queries
found = 0
value_space.times { |i|
  # since we're simulating a dump, these queries are free (elapsed: 0)
  if db_query(i, elapsed: 0)
    # a record was found; add it to the filter
    found += 1
    bf.add(i.to_s)
  end
}
puts "Checked #{value_space} values to load the filter with #{found} items"
puts bf
puts

#################

puts "Running queries straight to db..."
t = Time.new
counts = Hash.new(0)
iters = 99
iters.times { |i|
  puts format("%i: %s", i, db_query(i) || 'not found')
}
elapsed = Time.new - t
puts
puts format("%i queries direct to db: %.2f s elapsed", iters, elapsed)
puts
sleep 0.5

#################

puts "Running queries filtered by bloom filter..."
t = Time.new
counts = Hash.new(0)
iters = 99
iters.times { |i|
  puts format("%i: %s", i, bf.include?(i.to_s) ? db_query(i) : 'filtered')
}
elapsed = Time.new - t
puts
puts format("%i filtered queries: %.2f s elapsed", iters, elapsed)
puts
