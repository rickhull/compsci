require 'compsci/node'
require 'compsci/push_tree'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# Try out Binary, Ternary, and Quaternary PushTrees
# Push the same vals to each
#

EOF

vals = Array.new(30) { rand 99 }

[2, 3, 4].each { |children|
  my_vals = vals.dup
  p my_vals

  root = ChildFlexNode.new my_vals.shift
  tree = PushTree.new(root, child_slots: children)
  tree.push my_vals.shift until my_vals.empty?
  p tree
  puts root.display(width: 80)
  puts
  visited = []
  tree.df_search { |n|
    visited << n
    false # or n.value > 90
  }
  puts "df_search visited: %s" % visited.join(' ')
  puts
  puts

  # push different vals for each class
  my_vals = Array.new(30) { rand 99 }
  puts "push: #{my_vals.inspect}"
  tree.push my_vals.shift until my_vals.empty?
  puts
  puts root.display(width: 80)
  puts
  puts
}

puts <<EOF
#
# 30 inserts, puts, df_search
#

EOF

vals = Array.new(30) { rand 99 }
p vals

root = ChildFlexNode.new vals.shift
tree = PushTree.new root, child_slots: 2
tree.push vals.shift until vals.empty?
puts root.display

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
puts root.display
puts


secs = 5
puts <<EOF
#
# #{secs} seconds worth of pushes
#

EOF

count = 0
start = Timer.now
start_1k = Timer.now
tree = PushTree.new ChildFlexNode.new(rand(99)), child_slots: 2

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

  break if Timer.since(start) > secs
}

puts "pushed %i items in %0.1f s" % [count, Timer.since(start)]
puts
