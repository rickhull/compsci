require 'compsci/tree'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# Try out Binary-, Ternary-, and QuaternaryTree
#

EOF

vals = Array.new(30) { rand 99 }

[BinaryTree, TernaryTree, QuaternaryTree].each { |tree_class|
  # start with the same vals for each class
  my_vals = vals.dup
  p my_vals
  tree = tree_class.new(ChildNode, my_vals.shift)
  tree.push my_vals.shift until my_vals.empty?
  p tree
  puts tree
  puts

  tree.df_search { |n|
    puts "visited #{n}"
    false # or n.value > 90
  }
  puts

  # push different vals for each class
  my_vals = Array.new(30) { rand 99 }
  puts "push: #{my_vals.inspect}"

  tree.push my_vals.shift until my_vals.empty?
  puts tree
  puts
}
