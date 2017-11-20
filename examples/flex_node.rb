require 'compsci/flex_node'
require 'compsci/timer'

include CompSci

puts <<EOF

#
# Try out Binary, Ternary, and Quaternary FlexNodes
# Push the same vals to each
#

EOF

vals = Array.new(30) { rand 99 }

[2, 3, 4].each { |child_slots|
  my_vals = vals.dup
  p my_vals

  root = ChildFlexNode.new my_vals.shift
  root.push(my_vals.shift, child_slots) until my_vals.empty?
  p root
  puts root.display(width: 80)
  puts
  visited = []
  root.df_search { |n|
    visited << n
    false # or n.value > 90
  }
  puts "df_search visited: %s" % visited.join(' ')
  puts
  puts

  # push different vals for each class
  my_vals = Array.new(30) { rand 99 }
  puts "push: #{my_vals.inspect}"
  root.push(my_vals.shift, child_slots) until my_vals.empty?
  puts
  puts root.display(width: 80)
  puts
  puts
}

puts <<EOF

#
# 30 ChildFlexNode pushes and df_search
#

EOF

vals = Array.new(30) { rand 99 }
p vals

root = ChildFlexNode.new vals.shift
child_slots = 2
root.push(vals.shift, child_slots) until vals.empty?
p root
puts root.display
puts

root.df_search { |n|
  puts "visited #{n}"
  false # or n.value > 90
}
puts

vals = Array.new(30) { rand 99 }
puts "push: #{vals.inspect}"

root.push(vals.shift, child_slots) until vals.empty?
puts root.display
puts


runtime = (ARGV.shift || "3").to_i
puts <<EOF

#
# #{runtime} seconds worth of Binary ChildFlexNode pushes
#

EOF

count = 0
start = Timer.now
start_1k = Timer.now
root = ChildFlexNode.new(rand 99)
child_slots = 2

loop {
  count += 1

  if count % 100 == 0
    _ans, push_elapsed = Timer.elapsed {
      root.push(rand(99), child_slots)
    }
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
    root.push(rand(99), child_slots)
  end

  break if Timer.since(start) > runtime
}

puts "pushed %i items in %0.1f s" % [count, Timer.since(start)]
puts
