require 'compsci/heap'

include CompSci

puts <<EOF

#
# display the results of ternary Heap push and pop
#

EOF

h = Heap.new(child_slots: 3)

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %i" % h.pop
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %s" % Array.new(9) { h.pop }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts


puts <<EOF

#
# display the results of binary Heap push and pop
#

EOF

h = Heap.new(child_slots: 2)

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %i" % h.pop
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %s" % Array.new(9) { h.pop }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.tree.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
