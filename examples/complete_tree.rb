require 'compsci/complete_tree'

include CompSci

vals = Array.new(30) { rand 99 }
puts "initial vals: #{vals.inspect}"

[2, 3, 4].each { |child_slots|
  puts <<EOF

#
# Print CompleteTree(#{child_slots}) filled with static vals
#

EOF

  tree = CompleteTree.new(array: vals, child_slots: child_slots)
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
  puts "added vals: #{my_vals.inspect}"

  tree.push my_vals.shift until my_vals.empty?
  puts
  puts tree.display(width: 80)
  puts
  puts
}
