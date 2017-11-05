require 'compsci/binary_search_tree'

include CompSci

RANDMAX = 99

p vals = Array.new(15) { rand RANDMAX }

b = BinarySearchTree.new vals.shift
b.insert vals.shift until vals.empty?
puts b
