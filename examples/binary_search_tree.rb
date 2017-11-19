require 'compsci/node'
require 'compsci/names'

include CompSci

puts <<EOF

#
# Insert nodes into a BST (random keys, duplicates: true)
#

EOF

randmax = 99

p vals = Names::WW1.shuffle
p keys = Array.new(vals.size) { rand randmax }

root = KeyNode.new(vals.shift, key: keys.shift, children: 2, duplicates: true)
root.insert(keys.shift, vals.shift) until keys.empty?

puts root.display
puts

puts <<EOF

#
# Insert 30 nodes into a BST (unique keys, duplicates: false)
#

EOF

keys = (1..30).to_a.shuffle
vals = keys.map { rand 99 }

root = KeyNode.new(vals.shift, key: keys.shift, children: 2)
root.insert(keys.shift, vals.shift) while !keys.empty?
puts root.display

puts <<EOF

#
# Search for 30 different keys
#

EOF

(1..30).each { |key|
  node = root.search(key)
  puts "found #{node}"
}
