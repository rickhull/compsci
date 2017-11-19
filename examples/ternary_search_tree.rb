require 'compsci/node'
require 'compsci/names'

include CompSci

randmax = 50

puts <<EOF

#
# TERNARY SEARCH TREE: INSERT #{randmax} NODES (RANDOM KEYS)
#

EOF

root = KeyNode.new(rand(randmax), key: rand(randmax), children: 3)
randmax.times { puts root.insert(rand(randmax), rand(randmax)) }
puts root.display

puts <<EOF

#
# SEARCH FOR #{randmax} RANDOM KEYS
#

EOF

randmax.times { |key|
  puts "search #{key}: #{root.search(key).map { |n| n.value }.join(' ')}"
}
