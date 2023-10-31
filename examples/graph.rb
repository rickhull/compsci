require 'objspace'
require 'compsci/graph'

include CompSci

graph = MultiGraph.new
# collisions = 0

499_999.times { |i|
  #begin
    graph.edge(rand(4999), rand(4999), i)
  #rescue CompSci::MultiGraphError
  #  collisions += 1
  #end
}

# puts graph
#puts "#{collisions} collisions"
puts ObjectSpace.memsize_of(graph.edges)



if false
diamond = DAG.diamond

puts ObjectSpace.dump(diamond)
puts ObjectSpace.memsize_of(diamond)
puts
puts
puts ObjectSpace.dump(diamond.vtx)
puts ObjectSpace.memsize_of(diamond.vtx)
puts
puts
puts ObjectSpace.dump(diamond.edges)
puts ObjectSpace.memsize_of(diamond.edges)
end
