require 'set'
require 'compsci'

module CompSci
  class Vertex
    attr_reader :value, :meta

    def initialize(value = nil, **meta)
      @value = value
      @meta = meta
    end

    def to_s
      @value.to_s
    end
  end

  # Edge has references to 2 Vertices
  class Edge
    attr_reader :from, :to, :value, :meta

    def initialize(from, to, value = nil, **meta)
      @from = from
      @to = to
      @value = value
      @meta = meta
    end

    def to_s
      [@from, "-#{@value}->", @to].join(" ")
    end
  end

  # consists of Vertices connected by Edges
  class Graph
    def self.multigraph
      # multigraph, multiple edges between 0 and 1
      #
      #   __a__
      #  /     \
      # 0       1
      #  \__b__/
      #
      #                Graph: overwrite a with b
      #           MultiGraph: allow
      #         AcyclicGraph: overwrite a with b
      # DirectedAcyclicGraph: overwrite a with b
      #    Deterministic FSM: overwrite a with b

      graph = self.new
      (0..1).each { |i| graph.v i } # create 2 vertices, 0 and 1
      # create 2 edges, a and b, between 0 and 1
      v = graph.vtxs
      graph.e v[0], v[1], :a
      graph.e v[0], v[1], :b
      graph
    end

    def self.diamond
      # diamond pattern, starts at 0, ends at 3
      #     1
      #    / \
      #  a/   \c
      #  /     \
      # 0       3
      #  \     /
      #  b\   /d
      #    \ /
      #     2
      #
      #                Graph: allow
      #           MultiGraph: allow
      #         AcyclicGraph: raise CycleError
      # DirectedAcyclicGraph: allow
      #    Deterministic FSM: allow

      graph = self.new
      (0..3).each { |i| graph.v i } # create 4 vertices, 0-3
      # create 4 edges, a-d
      v = graph.vtxs
      graph.e v[0], v[1], :a
      graph.e v[0], v[2], :b
      graph.e v[1], v[3], :c
      graph.e v[2], v[3], :d
      graph
    end

    attr_reader :vtxs, :edge

    def initialize
      @vtxs = []
      @edge = {} # keyed by the *from* vertex
    end

    # add a new vtx to @vtxs
    def v(value, **kwargs)
      v = Vertex.new(value, **kwargs)
      @vtxs << v
      v
    end

    # add a new edge to @edge
    def e(from, to, value, **kwargs)
      e = Edge.new(from, to, value, **kwargs)
      self.add_edge! e
      e
    end

    # @edge[from][to] => Edge
    def add_edge! e
      @edge[e.from] ||= {}
      @edge[e.from][e.to] = e
      e
    end

    # return a flat list of edges
    def edges(from = nil)
      if from.nil?
        @edge.values.map(&:values).flatten
      else
        (@edge[from] || Hash.new).values
      end
    end

    # edges include vertices; one edge per line
    def to_s
      self.edges.join(NEWLINE)
    end
  end

  # allow multiple edges between any two vertices
  class MultiGraph < Graph
    # @edge[from] => [Edge, Edge, ...]
    def add_edge! e
      @edge[e.from] ||= []
      @edge[e.from] << e
      e
    end

    # return a flat list of edges
    def edges(from = nil)
      from.nil? ? @edge.values.flatten : (@edge[from] || Array.new)
    end
  end

  class CycleError < RuntimeError; end

  # Undirected Acyclic Graph, not a MultiGraph
  class AcyclicGraph < Graph
    attr_accessor :check_add

    def initialize
      @check_add = false
      super
    end

    def reset_search!
      @visited, @finished = {}, {}
      self
    end

    # @edge[from][to] => Edge; may raise CycleError, especially with @check_add
    def add_edge! e
      raise(CycleError, e) if e.from == e.to
      @edge[e.from] ||= {}
      @edge[e.from][e.to] = e
      if @check_add  # does the new edge create a cycle?
        vtx = e.from # start the *from* vertex; helpful for DAGs
        self.reset_search!
        self.dfs vtx # may raise CycleError
      end
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search!
      @vtxs.each { |v| self.dfs v }
      self
    end

    # recursive depth first search
    def dfs(v, skip = nil)
      return true if @finished[v]
      raise CycleError if @visited[v]
      @visited[v] = true

      # search every neighbor (but don't search back to v)
      self.edges.each { |e|
        if e.to == v and e.from != skip
          self.dfs(e.from, skip = v)
        elsif e.from == v and e.to != skip
          self.dfs(e.to, skip = v)
        end
      }
      @finished[v] = true
    end
  end

  class DirectedAcyclicGraph < AcyclicGraph
    # roots have nothing pointing *to* them
    def roots
      invalid = Set.new
      @edge.values.each { |hsh| invalid.merge(hsh.values.map(&:to)) }
      @vtxs - invalid.to_a
    end

    # perform depth first search on every root; may raise CycleError
    def check_cycle!
      roots = self.roots
      raise(CycleError, "invalid state: no roots") if roots.empty?
      self.reset_search!
      roots.each { |v| self.dfs(v) }
      self
    end

    # recursive depth first search, following directed edges
    def dfs(v)
      return true if @finished[v]
      raise CycleError if @visited[v]
      @visited[v] = true

      # search via from -> to
      @edge[v]&.values&.each { |e| self.dfs(e.to) }
      @finished[v] = true
    end
  end

  DAG = DirectedAcyclicGraph
end
