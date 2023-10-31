require 'objspace'
require 'compsci/graph'
require 'compsci/timer'

include CompSci

def add_edges(graph, deadline: 200, limit: 99_999)
  vtx_rand = 999
  vtx_rand = limit / 10 if limit <= vtx_rand
  collisions = 0
  cycles = 0
  t = Timer.new
  limit.times { |i|
    break if t.elapsed_ms > deadline
    begin
      graph.edge(rand(vtx_rand), rand(vtx_rand), i)
    rescue MultiGraphError
      collisions += 1
    rescue CycleError
      cycles += 1
    end
  }
  [collisions, cycles]
end

collisions = 0
graph = nil

# Graph
elapsed = Timer.elapsed {
  graph = Graph.new
  collisions, _cycles = add_edges(graph)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB) %i collisions",
            graph.class.to_s, edges.count,
            elapsed * 1000, memsize / 1024, collisions)

# MultiGraph
elapsed = Timer.elapsed {
  graph = MultiGraph.new
  add_edges(graph)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB)",
            graph.class.to_s, edges.count, elapsed * 1000, memsize / 1024)

# AcyclicGraph, check_add: false
cycles = 0

elapsed = Timer.elapsed {
  graph = AcyclicGraph.new(check_add: false)
  collisions, cycles = add_edges(graph)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB) %i collisions, %i loops",
            graph.class.to_s, edges.count, elapsed * 1000,
            memsize / 1024, collisions, cycles)

# AcyclicGraph#check_cycle!
acyclic = true

elapsed = Timer.elapsed {
  begin
    graph.check_cycle!
  rescue CycleError
    acyclic = false
  end
}[1]
puts format("Cycle found: %s; within %i ms", !acyclic, elapsed * 1000)

# AcyclicGraph, check_add: true
elapsed = Timer.elapsed {
  graph = AcyclicGraph.new(check_add: true)
  collisions, cycles = add_edges(graph, limit: 999)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB) %i collisions, %i cycles",
            graph.class.to_s, edges.count, elapsed * 1000,
            memsize / 1024, collisions, cycles)

# AcyclicGraph#check_cycle!
acyclic = true
elapsed = Timer.elapsed {
  begin
    graph.check_cycle!
  rescue CycleError => e
    puts e.detailed_message
    acyclic = false
  end
}[1]
puts format("Cycle found: %s; within %i ms", !acyclic, elapsed * 1000)


# DAG
elapsed = Timer.elapsed {
  graph = DAG.new(check_add: false)
  collisions, cycles = add_edges(graph)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB) %i collisions, %i loops",
            graph.class.to_s, edges.count, elapsed * 1000,
            memsize / 1024, collisions, cycles)

# DAG#check_cycle!
acyclic = true
elapsed = Timer.elapsed {
  begin
    graph.check_cycle!
  rescue CycleError
    acyclic = false
  end
}[1]
puts format("Cycle found: %s; within %i ms", !acyclic, elapsed * 1000)


# DAG, check_add: true
elapsed = Timer.elapsed {
  graph = DAG.new(check_add: true)
  collisions, cycles = add_edges(graph, limit: 1999)
}[1]
edges = graph.edges
memsize = ObjectSpace.memsize_of(edges)
puts format("%s(%i) created in %i ms (%i KB) %i collisions, %i cycles",
            graph.class.to_s, edges.count, elapsed * 1000,
            memsize / 1024, collisions, cycles)

# DAG#check_cycle!
acyclic = true
elapsed = Timer.elapsed {
  begin
    graph.check_cycle!
  rescue CycleError => e
    puts e.detailed_message
    acyclic = false
  end
}[1]
puts format("Cycle found: %s; within %i ms", !acyclic, elapsed * 1000)
