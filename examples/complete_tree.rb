require 'compsci/complete_tree'

include CompSci

vals = Array.new(30) { rand 99 }

[CompleteBinaryTree,
 CompleteTernaryTree,
 CompleteQuaternaryTree].each { |tree_class|

  puts <<EOF

#
# Print #{tree_class} filled with static vals
#

EOF

  my_vals = vals.dup
  puts "initial vals: #{my_vals.inspect}"
  tree = tree_class.new
  tree.push my_vals.shift until my_vals.empty?

  p tree
  puts
  puts tree.display(width: 80)
  puts


  puts <<EOF

#
# Push random vals and print again
#

EOF

  my_vals = Array.new(30) { rand 99 }
  puts "new vals: #{my_vals.inspect}"

  tree.push my_vals.shift until my_vals.empty?
  puts
  puts tree.display(width: 80)
  puts
  puts
}
