require 'set'                 # used by DAG to determine root vertices for DFS
require 'compsci'             # CompSci::NEWLINE
require 'compsci/graph/error' # CompSci::CycleError, CompSci::MultiGraphError

module CompSci
  # represents an edge between two vertices, *src* and *dest*
  class Edge
    attr_reader :src, :dest, :value, :meta

    # src, dest, value can be any Ruby object, probably string / symbol / int
    def initialize(src, dest, value = nil, **meta)
      @src = src
      @dest = dest
      @value = value
      @meta = meta   # not currently used; but it may be
    end

    def to_s
      [@src, "--#{@value}-->", @dest].join(" ")
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
      @vtx = {}  # keyed by vertex, used like a Set
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
      @vtx[src] ||= true
      @vtx[dest] ||= true
      self.add_edge e
    end

    # check both directions
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

    # return a flat list of vertices
    def vtxs
      @vtx.keys
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

    # check both directions
    def edge_between?(src, dest)
      edges = []
      edges += @edge[src].select { |e| e.dest == dest } if @edge[src]
      edges += @edge[dest].select { |e| e.dest == src } if @edge[dest]
      !edges.empty?
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

    def initialize
      @check_add = false
      super
    end

    def reset_search!
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
        self.reset_search!
        self.dfs e.src # may raise CycleError
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
        if e.dest == v and e.src != skip
          self.dfs(e.src, skip = v)
        elsif e.src == v and e.dest != skip
          self.dfs(e.dest, skip = v)
        end
      }
      @finished[v] = true
    end
  end

  class DirectedAcyclicGraph < AcyclicGraph
    # roots have nothing pointing *to* them
    def roots
      invalid = Set.new
      @edge.each_value { |hsh| invalid.merge(hsh.values.map(&:dest)) }
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

      # search via src -> dest
      @edge[v]&.each_value { |e| self.dfs(e.dest) }
      @finished[v] = true
    end
  end

  DAG = DirectedAcyclicGraph
end
