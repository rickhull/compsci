require 'compsci/node'
require 'compsci/tree'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# Try out Binary-, Ternary-, and QuaternaryTree
#

EOF

vals = Array.new(30) { rand 99 }

# [BinaryTree, TernaryTree, QuaternaryTree].each { |tree_class|
[2, 3, 4].each { |slots|
  # start with the same vals for each class
  my_vals = vals.dup
  p my_vals
  root = ChildFlexNode.new my_vals.shift
  tree = PushTree.new(root, child_slots: slots)
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
