require 'set'

module CompSci
  NEWLINE = $/ # platform-default line separator

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

  # allow multiple edges between any two vertices
  class MultiGraph
    def self.multigraph
      # multigraph, multiple edges between 0 and 1
      #
      #   __a__
      #  /     \
      # 0       1
      #  \__b__/
      #
      # MG should allow
      # AG should not allow
      # DAG should not allow
      # Deterministic FSM should not allow

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
      # MG should allow
      # AG should not allow
      # DAG should allow
      # Deterministic FSM should allow

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
      @edge = {}
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

    # @edge[from] => [Edge, Edge, ...]
    def add_edge! e
      @edge[e.from] ||= []
      @edge[e.from] << e
      e
    end

    # return a flat list of edges
    def edges(from = nil)
      from.nil? ? @edge.values.flatten : @edge[from]
    end

    # edges include vertices; one edge per line
    def to_s
      self.edges.join(NEWLINE)
    end
  end

  class CycleError < RuntimeError; end

  # Undirected Acyclic Graph
  class AcyclicGraph < MultiGraph
    attr_accessor :check_add

    def initialize
      @check_add = false
      super
    end

    def reset_search!
      @visited, @finished = {}, {}
    end

    # @edge[from][to] => Edge; may raise CycleError if @check_add == true
    def add_edge! e
      raise(CycleError, e) if e.from == e.to
      @edge[e.from] ||= {}
      @edge[e.from][e.to] = e
      if @check_add  # does the new edge create a cycle?
        vtx = e.from # start the *from* vertex; helpful for DAGs
        # puts "searching #{vtx.value}"
        self.reset_search!
        self.dfs vtx # this can raise CycleError
      end
      e
    end

    # return a flat list of edges
    def edges(from = nil)
      from.nil? ? @edge.values.map(&:values).flatten : @edge[from].values
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search!
      @vtxs.each { |v|
        # puts
        # puts "SEARCH #{v.value}"
        self.dfs v
      }
    end

    # recursive depth first search
    def dfs(v, skip = nil)
      #puts "skip: #{skip}"
      #puts "vertex: #{v}"
      #puts "visited: #{@visited.keys.map(&:to_s)}"
      #puts "finished: #{@finished.keys.map(&:to_s)}"
      return true if @finished[v]
      raise CycleError if @visited[v]
      @visited[v] = true

      # search every neighbor (but don't search back to v)
      @edge.values.each { |hsh|
        hsh.values.each { |e|
          if e.to == v and e.from != skip
            self.dfs(e.from, skip = v)
          elsif e.from == v and e.to != skip
            self.dfs(e.to, skip = v)
          end
        }
      }
      # puts "FINISH #{v.value}"
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
      roots.each { |v|
        # puts "searching #{v.value}"
        self.dfs(v)
      }
    end

    # recursive depth first search, following directed edges
    def dfs(v)
      return true if @finished[v]
      raise CycleError if @visited[v]
      @visited[v] = true

      # search via from -> to (but don't search back to v)
      @edge[v]&.values&.each { |e| self.dfs(e.to) }
      # puts "finished #{v.value}"
      @finished[v] = true
    end
  end

  DAG = DirectedAcyclicGraph

  # Deterministic Acyclic Finite State Acceptor
  #
  class DAFSAcceptor
    class DeterministicError < RuntimeError; end

    attr_reader :dag, :first, :id
    attr_accessor :final

    def initialize
      @dag = DAG.new
      @id = 0
      @first = self.new_state
    end

    def states
      @dag.vtxs
    end

    def new_state
      state, @id = @dag.v(@id), @id + 1
      state
    end

    def add_state(from_state, input)
      to_state = self.new_state
      @dag.e from_state, to_state, input
      to_state
    end

    def add_final(from_state, input)
      @final = self.add_state(from_state, input)
    end

    def to_s
      [[@first, @final].map(&:value).inspect, @dag].join(NEWLINE)
    end

    def accept?(input)
      cursor = @first
      input.each_char { |chr|
        hsh = @dag.edge[cursor]
        return false if hsh.nil?
        edges = hsh.values.select { |e| e.value == chr }
        case edges.count
        when 0
          return false
        when 1 # ok
          cursor = edges[0].to
        else
          raise(DeterministicError, "multiple edges for #{chr} from #{cursor}")
        end
      }
      cursor == @final
    end
  end

  DAFSA = DAFSAcceptor
end
