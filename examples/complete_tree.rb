require 'compsci/complete_tree'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# Print CompleteBinary-, Ternary-, and QuaternaryTree
#

EOF

vals = Array.new(30) { rand 99 }

[CompleteBinaryTree,
 CompleteTernaryTree,
 CompleteQuaternaryTree,
].each { |tree_class|
  # start with the same vals for each class
  my_vals = vals.dup
  p my_vals
  tree = tree_class.new
  tree.push my_vals.shift until my_vals.empty?
  p tree
  puts tree.display(width: 80)
  puts
  puts
  puts


  # TODO: add CompleteTree#df_search
  # tree.df_search { |n|
  #   puts "visited #{n}"
  #   false # or n.value > 90
  # }
  # puts

  # push different vals for each class
  my_vals = Array.new(30) { rand 99 }
  puts "push: #{my_vals.inspect}"

  tree.push my_vals.shift until my_vals.empty?
  puts tree.display(width: 80)
  puts
  puts
  puts
}
