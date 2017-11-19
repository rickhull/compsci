require 'compsci/complete_tree'

include CompSci

vals = Array.new(30) { rand 99 }

[CompleteBinaryTree,
 CompleteTernaryTree,
 CompleteQuaternaryTree].each { |tree_class|

  puts <<EOF

#
# Print #{tree_class}
#

EOF

  # start with the same vals for each class
  my_vals = vals.dup
  puts "initial vals: #{my_vals.inspect}"
  tree = tree_class.new
  tree.push my_vals.shift until my_vals.empty?

  p tree
  puts
  puts tree.display(width: 80)
  puts
  puts


  # push different vals for each class
  my_vals = Array.new(30) { rand 99 }
  puts "new vals: #{my_vals.inspect}"

  tree.push my_vals.shift until my_vals.empty?
  puts
  puts tree.display(width: 80)
  puts
  puts
}
