require 'compsci/node'
require 'compsci/binary_search_tree'
require 'compsci/names'

include CompSci

RANDMAX = 99

p vals = Names::WW1.shuffle
p keys = Array.new(vals.size) { rand RANDMAX }

root = BinarySearchTree.new_node(keys.shift, vals.shift)
tree = BinarySearchTree.new(root)
tree[keys.shift] = vals.shift until keys.empty?
# tree.insert(keys.shift, vals.shift) until keys.empty?
puts tree
