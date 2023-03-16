require 'set'
require 'compsci'

module CompSci
  # represents an edge between two vertices, *from* and *to*
  # the vertices can be any Ruby object, probably string / symbol / int
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
    class UnknownVertex < RuntimeError; end
    class CycleError < RuntimeError; end

    attr_reader :vtx

    def initialize
      @vtx = {}  # keyed by vertex, used like a Set
      @edge = {} # keyed by the *from* vertex
    end

    # add a new edge to @edge, adding vertices to @vtx as needed
    def edge(from_value, to_value, value, **kwargs)
      # create vertices as needed; used like a Set
      @vtx[from_value] ||= true
      @vtx[to_value] ||= true
      self.add_edge! Edge.new(from_value, to_value, value, **kwargs)
    end

    # @edge[from][to] => Edge
    def add_edge! e
      @edge[e.from] ||= {}
      @edge[e.from][e.to] = e
    end

    # iterate edges like: graph.each_edge { |e| puts e }
    def each_edge(from: nil, to: nil, value: nil)
      # filter on *from*
      if from
        return self unless @edge.key? from
        hsh = @edge[from]
        if hsh.nil? or hsh.empty? or !hsh.is_a? Hash
          raise(UnexpectedError, hsh.inspect)
        end

        # filter on *to*
        if to
          return self unless hsh.key? to
          edge = hsh[to]
          if edge.nil? or !edge.is_a? Edge
            raise(UnexpectedError, edge.inspect)
          end
          # filter on *value*
          return self if value and edge.value != value
          yield edge
        else
          hsh.each_value { |e|
            next if value and e.value != value
            yield e
          }
        end
      else
        @edge.values.each { |hsh|
          hsh.each_value { |e|
            next if to and e.to != to
            next if value and e.value != value
            yield e
          }
        }
      end
      self
    end

    # return a flat list of edges
    def edges(from: nil, to: nil, value: nil)
      ary = []
      self.each_edge(from: from, to: to, value: value) { |e| ary << e }
      ary
    end

    # edges include vertices; one edge per line
    def to_s
      self.edges.join(NEWLINE)
    end

    # return a flat list of vertices
    def vtxs
      @vtx.keys
    end

    #
    # Pre-made patterns
    #

    def self.loop1
      graph = self.new
      graph.edge 0, 0, :loop
      graph
    end

    def self.loop2
      graph = self.new
      graph.edge 0, 1, :out
      graph.edge 1, 0, :back
      graph
    end

    def self.loop3
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 1, 2, :b
      graph.edge 2, 0, :c
      graph
    end

    def self.multigraph
      # multigraph, multiple edges between 0 and 1
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

  # allow multiple edges between any two vertices
  # store edges with Array rather than Hash
  class MultiGraph < Graph
    # @edge[from] => [Edge, Edge, ...]
    def add_edge! e
      @edge[e.from] ||= []
      @edge[e.from] << e
      e
    end

    def each_edge(from: nil, to: nil, value: nil)
      if from
        return self unless @edge.key? from
        ary = @edge[from]
        if ary.nil? or ary.empty? or !ary.is_a? Array
          raise(UnexpectedError, ary.inspect)
        end

        ary.each { |e|
          next if to and e.to != to
          next if value and e.value != value
          yield e
        }
      else
        @edge.values.each { |ary|
          ary.each { |e|
            next if to and e.to != to
            next if value and e.value != value
            yield e
          }
        }
      end
      self
    end
  end

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
        self.reset_search!
        self.dfs e.from # may raise CycleError
      end
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search!
      @vtx.each_key { |value| self.dfs value }
      self
    end

    # recursive depth first search; may raise CycleError
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
      @edge.each_value { |hsh| invalid.merge(hsh.values.map(&:to)) }
      @vtx.keys - invalid.to_a
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
      @edge[v]&.each_value { |e| self.dfs(e.to) }
      @finished[v] = true
    end
  end

  DAG = DirectedAcyclicGraph
end
