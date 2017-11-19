require 'compsci/node'
require 'compsci/names'

include CompSci

puts <<EOF

#
# INSERT NODES INTO A BST (RANDOM KEYS)
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
# INSERT 30 NODES INTO A BST (UNIQUE KEYS)
#

EOF

keys = (1..30).to_a.shuffle
vals = keys.map { rand 99 }

root = KeyNode.new(vals.shift, key: keys.shift, children: 2)
root.insert(keys.shift, vals.shift) while !keys.empty?
puts root.display

puts <<EOF

#
# SEARCH FOR 30 DIFFERENT KEYS
#

EOF

(1..30).each { |key|
  node = root.search(key)
  puts "found #{node}"
}



puts <<EOF

#
# INSERT 30 NODES INTO A TST (NON-UNIQUE KEYS)
#

EOF

randmax = 50

root = KeyNode.new(rand(randmax), key: rand(randmax), children: 3)
29.times { puts root.insert(rand(randmax), rand(randmax)) }
puts root.display

puts <<EOF

#
# SEARCH FOR #{randmax} RANDOM KEYS
#

EOF

randmax.times { |key|
  puts "search #{key}: #{root.search(key).map { |n| n.value }.join(' ')}"
}
