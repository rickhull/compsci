require 'compsci/graph'

# Pre-made patterns
# Note: these are available for Graph and all its subclasses (self.new)
module CompSci
  class Graph
    # single vertex; allowed by anything not Acyclic
    def self.loop1
      graph = self.new
      graph.edge 0, 0, :loop
      graph
    end

    # two vertices; creates a MultiGraph; allowed by MultiGraph
    def self.loop2
      graph = self.new
      graph.edge 0, 1, :out
      graph.edge 1, 0, :back
      graph
    end

    # three vertices; allowed by anything not Acyclic
    def self.loop3
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 1, 2, :b
      graph.edge 2, 0, :c
      graph
    end

    def self.multigraph
      # multigraph, multiple (possibly directed) edges between 0 and 1
      #
      #   __a__                 Graph: overwrite a with b
      #  /     \           MultiGraph: allow
      # 0       1        AcyclicGraph: overwrite a with b
      #  \__b__/                  DAG: overwrite a with b
      #                           FSM: allow
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 0, 1, :b
      graph
    end

    def self.diamond
      # diamond pattern, starts at 0, ends at 3
      #     1
      #    / \                  Graph: allow
      #  a/   \c           MultiGraph: allow
      #  /     \         AcyclicGraph: raise CycleError
      # 0       3                 DAG: allow
      #  \     /                  FSM: allow
      #  b\   /d
      #    \ /
      #     2
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 0, 2, :b
      graph.edge 1, 3, :c
      graph.edge 2, 3, :d
      graph
    end

    def self.fork
      # fork pattern, 3 nodes, two edges with the same value
      #     1
      #    /                    Graph: allow
      #  a/                Multigraph: allow
      #  /               AcyclicGraph: allow
      # 0                         DAG: allow
      #  \          Deterministic FSM: reject 2nd edge
      #  a\      NonDeterministic FSM: allow
      #    \
      #     2
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 0, 2, :a
      graph
    end
  end
end
