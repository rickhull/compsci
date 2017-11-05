require 'compsci/binary_search_tree'

include CompSci

b = BinarySearchTree.new rand 99
15.times { b.insert rand 99 }
puts b
