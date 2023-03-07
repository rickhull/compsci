require 'set'

module CompSci
  NEWLINE = $/ # platform-default line separator

  class Vertex
    attr_reader :contents, :meta

    def initialize(contents = nil, **meta)
      @contents = contents
      @meta = meta
    end

    def to_s
      @contents.to_s
    end
  end

  class Edge
    attr_reader :from, :to, :contents, :meta

    def initialize(from, to, contents = nil, **meta)
      @from = from
      @to = to
      @contents = contents
      @meta = meta
    end

    def to_s
      [@from, "-#{@contents}->", @to].join(" ")
    end
  end

  class CycleError < RuntimeError; end

  # Undirected Acyclic Graph
  class AcyclicGraph

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
      # AG should not allow
      # DAG should allow
      # Deterministic FSM should allow

      graph = self.new
      (0..3).each { |i| graph.v i }
      # create 4 edges, a-d
      v = graph.vtxs
      graph.e v[0], v[1], :a
      graph.e v[0], v[2], :b
      graph.e v[1], v[3], :c
      graph.e v[2], v[3], :d
      graph
    end

    def self.multipath
      # multipath, starts at 0, ends at 1
      #
      #   __a__
      #  /     \
      # 0       1
      #  \__b__/
      #
      # AG should not allow
      # DAG should allow
      # Deterministic FSM should not allow

      graph = self.new
      (0..1).each { |i| graph.v i }
      v = graph.vtxs
      graph.e v[0], v[1], :a
      graph.e v[0], v[1], :b
      graph
    end

    attr_accessor :check_add
    attr_reader :vtxs, :edge

    def initialize
      @check_add = false
      @vtxs = []
      @edge = {}
    end

    # add a new vtx to @vtxs
    def v(contents, **kwargs)
      v = Vertex.new(contents, **kwargs)
      @vtxs << v
      v
    end

    # add a new edge to @edge; @edge[from][to] => Edge
    def e(from, to, contents, **kwargs)
      e = Edge.new(from, to, contents, **kwargs)
      self.add_edge! e
      e
    end

    # return a flat list of edges
    def edges(from = nil)
      if from.nil?
        @edge.values.flatten
      else
        @edge[from]
      end
    end

    # edges include vertices; one edge per line
    def to_s
      self.edges.map(&:to_s).join(NEWLINE)
    end

    def reset_search!
      @visited, @finished = {}, {}
    end

    # @edge[from] => [Edge, ... ]; may raise CycleError if @check_add == true
    def add_edge! e
      raise(CycleError, e) if e.from == e.to
      @edge[e.from] ||= []
      @edge[e.from] << e
      if @check_add  # does the new edge create a cycle?
        vtx = e.from # start the *from* vertex; helpful for DAGs
        # puts "searching #{vtx.contents}"
        self.reset_search!
        self.dfs vtx # this can raise CycleError
      end
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search!
      @vtxs.each { |v|
        # puts
        # puts "SEARCH #{v.contents}"
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
      @edge.values.each { |ary|
        ary.each { |e|
          if e.to == v and e.from != skip
            self.dfs(e.from, skip = v)
          elsif e.from == v and e.to != skip
            self.dfs(e.to, skip = v)
          end
        }
      }
      # puts "FINISH #{v.contents}"
      @finished[v] = true
    end
  end

  class DirectedAcyclicGraph < AcyclicGraph
    # roots have nothing pointing *to* them
    def roots
      invalid = Set.new
      @edge.values.each { |ary| invalid.merge(ary.map(&:to)) }
      @vtxs - invalid.to_a
    end

    # perform depth first search on every root; may raise CycleError
    def check_cycle!
      roots = self.roots
      raise(CycleError, "invalid state: no roots") if roots.empty?
      self.reset_search!
      roots.each { |v|
        # puts "searching #{v.contents}"
        self.dfs(v)
      }
    end

    # recursive depth first search, following directed edges
    def dfs(v)
      return true if @finished[v]
      raise CycleError if @visited[v]
      @visited[v] = true

      # search via from -> to (but don't search back to v)
      @edge[v]&.each { |e| self.dfs(e.to) }
      # puts "finished #{v.contents}"
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
      [[@first, @final].map(&:contents).inspect, @dag].join(NEWLINE)
    end

    def accept?(input)
      cursor = @first
      input.each_char { |chr|
        hsh = @dag.edge[cursor]
        return false if hsh.nil?
        edges = hsh.values.select { |e| e.contents == chr }
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
