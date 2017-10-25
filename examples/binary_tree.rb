require 'compsci/tree'

include CompSci

vals = []
30.times { vals << rand(99) }
p vals

root_node = Tree::Node.new vals.shift
tree = BinaryTree.new(root_node)
tree.push vals.shift until vals.empty?

tree.bf_print

tree.df_search { |n|
  puts "visited #{n}"
  false # or n.value > 90
}
puts

p tree
