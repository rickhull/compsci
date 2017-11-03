require 'compsci/tree'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# 3 seconds worth of pushes
#

EOF

count = 0
start = Timer.now
start_1k = Timer.now
tree = BinaryTree.new ChildNode, rand(99)

loop {
  count += 1

  if count % 100 == 0
    _ans, push_elapsed = Timer.elapsed { tree.push rand 99 }
    puts "%ith push: %0.8f s" % [count, push_elapsed]

    if count % 1000 == 0
      push_1k_elapsed = Timer.since start_1k
      puts "-----------"
      puts "    1k push: %0.4f s (%i push / s)" %
           [push_1k_elapsed, 1000.to_f / push_1k_elapsed]
      puts
      start_1k = Timer.now
    end
  else
    tree.push rand 99
  end

  break if Timer.since(start) > 3
}

puts "pushed %i items in %0.1f s" % [count, Timer.since(start)]
puts

puts <<EOF
#
# 30 inserts, puts, df_search
#

EOF

vals = Array.new(30) { rand 99 }
p vals

tree = BinaryTree.new ChildNode, vals.shift
tree.push vals.shift until vals.empty?
puts tree

p tree
puts

tree.df_search { |n|
  puts "visited #{n}"
  false # or n.value > 90
}
puts

vals = Array.new(30) { rand 99 }
puts "push: #{vals.inspect}"

tree.push vals.shift until vals.empty?
puts tree
puts