require 'compsci/node'
require 'compsci/names'

include CompSci

randmax = (ARGV.shift || 50).to_i

puts <<EOF

#
# Insert #{randmax} nodes into a ternary search tree (random keys)
#

EOF

root = KeyNode.new(rand(randmax), key: rand(randmax), children: 3)
randmax.times { puts root.insert(rand(randmax), rand(randmax)) }
puts root.display

puts <<EOF

#
# Search for #{randmax} keys in order
#

EOF

randmax.times { |key|
  puts "search #{key}: #{root.search(key).map { |n| n.value }.join(' ')}"
}
