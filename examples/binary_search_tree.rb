require 'compsci/node'
require 'compsci/binary_search_tree'
require 'compsci/names'

include CompSci

RANDMAX = 99

p vals = Names::WW1.shuffle
p keys = Array.new(vals.size) { rand RANDMAX }

tree = BinarySearchTree.create(keys.shift, vals.shift)
tree[keys.shift] = vals.shift until keys.empty?

puts tree.root.display
