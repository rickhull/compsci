require 'compsci/heap'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# display the results of TernaryHeap push and pop
#

EOF

h = Heap.new(child_slots: 3)

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %i" % h.pop
puts "array: #{h.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "pop: %s" % Array.new(9) { h.pop }.join(' ')
puts "array: #{h.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
puts

puts "push: %s" % Array.new(30) { rand(99).tap { |i| h.push i } }.join(' ')
puts "array: #{h.array.inspect}"
puts "heap: #{h.heap?}"
puts h
puts
