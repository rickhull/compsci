require 'set'
require 'compsci'             # CompSci::NEWLINE
require 'compsci/graph/error' # CompSci::CycleError, CompSci::MultiGraphError

module CompSci
  # represents an edge between two vertices, *src* and *dest*
  Edge = Data.define(:src, :dest, :value) do
    def initialize(src:, dest:, value: nil)
      super(src: src, dest: dest, value: value)
    end

    def to_s
      format("%s --%s--> %s", src, value, dest)
    end
  end

  # consists of Vertices connected by Edges
  class Graph
    def self.multigraph!(edge)
      raise(MultiGraphError, format("%s is the second edge between %s and %s",
                                    edge, edge.dest, edge.src))
    end

    attr_reader :vtx

    def initialize
      @vtx  = Set.new
      @edge = {} # keyed by the *src* vertex
    end

    # add a new edge to @edge, adding vertices to @vtx as needed
    def edge(src, dest, value, **kwargs)
      # check if this would create MultiGraph
      e = Edge.new(src, dest, value, **kwargs)
      if !self.is_a? MultiGraph and self.edge_between?(dest, src)
        self.class.multigraph!(e)
      end

      # create vertices as needed; used like a Set
      @vtx.add(src)
      @vtx.add(dest)
      self.add_edge e
    end

    # check both directions; return any edge found
    def edge_between?(src, dest)
      @edge.dig(src, dest) or @edge.dig(dest, src)
    end

    # @edge[src][dest] => Edge; MultiGraph uses a different array impl
    def add_edge e
      @edge[e.src] ||= {}
      @edge[e.src][e.dest] = e
    end

    # return the (dest) vertex for an edge matching (src, value)
    def follow(src, value)
      hsh = @edge[src] or return false
      dests = hsh.values.select { |e| e.value == value }.map(&:dest)
      return false if dests.empty?
      dests.sample
    end

    # iterate edges like: graph.each_edge(**filters) { |e| puts e }
    def each_edge(src: nil, dest: nil, value: nil)
      # filter on *src*
      if src
        return self unless @edge.key? src
        hsh = @edge[src]
        if hsh.nil? or hsh.empty? or !hsh.is_a? Hash
          raise(UnexpectedError, hsh.inspect)
        end
        # filter on *dest*
        if dest
          return self unless hsh.key? dest
          edge = hsh[dest]
          if edge.nil? or !edge.is_a? Edge
            raise(UnexpectedError, edge.inspect)
          end
          # filter on *value*
          return self if value and edge.value != value
          yield edge
        # filter on *value* (with *src*)
        else
          hsh.each_value { |e|
            next if value and e.value != value
            yield e
          }
        end
      # filter on *dest* and *value*
      else
        @edge.values.each { |hsh|
          hsh.each_value { |e|
            next if dest and e.dest != dest
            next if value and e.value != value
            yield e
          }
        }
      end
      self
    end

    # return a flat list of edges
    def edges(src: nil, dest: nil, value: nil)
      ary = []
      self.each_edge(src: src, dest: dest, value: value) { |e| ary << e }
      ary
    end

    # edges include vertices; one edge per line
    def to_s
      self.edges.join(NEWLINE)
    end
  end

  # allow multiple edges between any two vertices
  # store edges with Array rather than Hash
  class MultiGraph < Graph
    # @edge[src] => [Edge, Edge, ...]
    def add_edge e
      @edge[e.src] ||= []
      @edge[e.src] << e
      e
    end

    # check both directions; return any edge found
    def edge_between?(src, dest)
      @edge[src].each { |e| return e if e.dest == dest } if @edge[src]
      @edge[dest].each { |e| return e if e.dest == src } if @edge[dest]
      false
    end

    # iterate edges like: graph.each_edge(**filters) { |e| puts e }
    def each_edge(src: nil, dest: nil, value: nil)
      if src
        return self unless @edge.key? src
        ary = @edge[src]
        if ary.nil? or ary.empty? or !ary.is_a? Array
          raise(UnexpectedError, ary.inspect)
        end

        ary.each { |e|
          next if dest and e.dest != dest
          next if value and e.value != value
          yield e
        }
      else
        @edge.values.each { |ary|
          ary.each { |e|
            next if dest and e.dest != dest
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

    def initialize(check_add: false)
      @check_add = check_add
      super()
    end

    def reset_search
      @visited, @finished = {}, {}
      self
    end

    # @edge[src][dest] => Edge, like Graph
    # may raise CycleError, especially with @check_add
    def add_edge e
      raise(CycleError, e) if e.src == e.dest
      @edge[e.src] ||= {}
      @edge[e.src][e.dest] = e
      if @check_add  # does the new edge create a cycle?
        self.reset_search
        begin
          self.check_cycle!
          # self.dfs e.src # may raise CycleError
        rescue CycleError => error
          @edge[e.src].delete(e.dest)
          raise error
        end
      end
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search
      @vtx.each { |v| self.dfs v }
      self
    end

    # recursive depth first search; may raise CycleError
    def dfs(v, skip = nil)
      return true if @finished[v]
      raise(CycleError, "dfs(#{v})") if @visited[v]
      @visited[v] = true

      # search every neighbor (but don't search back to v)
      self.each_edge { |e|
        if e.dest == v and e.src != skip
          self.dfs(e.src, skip = v)
        elsif e.src == v and e.dest != skip
          self.dfs(e.dest, skip = v)
        end
      }
      @finished[v] = true
    end
  end
  FOREST = AcyclicGraph

  class DirectedAcyclicGraph < AcyclicGraph
    # roots have nothing pointing *to* them
    def roots
      invalid = Set.new
      @edge.each_value { |hsh| invalid.merge(hsh.values.map(&:dest)) }
      @vtx - invalid
    end

    # perform depth first search on every root; may raise CycleError
    def check_cycle!
      roots = self.roots
      raise(CycleError, "invalid state: no roots") if roots.empty?
      self.reset_search
      roots.each { |v| self.dfs(v) }
      self
    end

    # recursive depth first search, following directed edges
    def dfs(v)
      return true if @finished[v]
      raise(CycleError, "dfs(#{v})") if @visited[v]
      @visited[v] = true

      # search via src -> dest
      @edge[v]&.each_value { |e| self.dfs(e.dest) }
      @finished[v] = true
    end
  end
  DAG = DirectedAcyclicGraph
end
