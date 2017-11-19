require 'compsci/node'

include CompSci

puts <<EOF

#
# Fill up and display some trees
#

EOF

vals = Array.new(30) { rand 99 }
puts "vals: #{vals.inspect}"

[2, 3, 4].each { |children|
  my_vals = vals.dup

  puts <<EOF

#
# Children: #{children}
#

EOF


  root = Node.new my_vals.shift, children: children
  nodes = [root]
  until my_vals.empty?
    new_nodes = []
    nodes.each { |node|
      children.times { |i|
        node[i] = Node.new my_vals.shift, children: children
      }
      new_nodes += node.children
    }
    nodes = new_nodes
  end
  p root
  puts
  puts root.display(width: 80)
  puts
}
