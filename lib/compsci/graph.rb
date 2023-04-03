require 'set'

module CompSci
  class CycleError < RuntimeError; end
  class MultiGraphError < RuntimeError; end
  class UnexpectedError < RuntimeError; end

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
    attr_reader :vtx

    def initialize
      @vtx  = Set.new
      @edge = {} # keyed by the *src* vertex
    end

    # add a new edge to @edge, adding vertices to @vtx as needed
    def edge(src, dest, value)
      # check if this would create MultiGraph
      e = Edge.new(src, dest, value)
      if !self.is_a? MultiGraph and self.edge_between?(dest, src)
        raise(MultiGraphError, e.to_s)
      end

      self.add_edge e
    end

    def assert_edge(src: nil, dest: nil, value: nil)
      edges = self.edges(src: src, dest: dest, value: value)
      case edges.count
      when 0
        raise(UnexpectedError, "no edges found")
      when 1
        edges[0]
      else
        raise(UnexpectedError, "multiple edges found: #{edges.inspect}")
      end
    end

    # @edge[src][dest] => Edge; MultiGraph uses a different array impl
    def add_edge e
      @edge[e.src] ||= {}
      @edge[e.src][e.dest] = e
      @vtx.add(e.src)
      @vtx.add(e.dest)
    end

    def delete(edge)
      @edge.each_value { |hsh| hsh.delete_if { |_, e| e == edge } }
      self
    end

    def clear!(src: nil, dest: nil, value: nil)
      if src
        hsh = @edge[src] or return
        if dest
          if value # (src, dest, value)
            hsh.delete(dest) if hsh[dest]&.value == value
          else     # (src, dest, _)
            hsh.delete(dest)
          end
        else
          if value # (src, _, value)
            hsh.delete_if { |_, e| e.value == value }
          else     # (src, _, _)
            @edge.delete(src)
          end
        end
      else                                          # (_, ?, ?)
        @edge.each_value { |hsh|
          if dest
            if value                                # (_, dest, value)
              hsh.delete(dest) if edge[dest]&.value == value
            else                                    # (_, dest, _)
              hsh.delete(dest)
            end
          else                                      # (_, _, ?)
            hsh.delete_if { |_, e| value and e.value == value }
          end
        }
      end
    end

    # remove empty structures; update @vtx
    def clean!
      @edge.delete_if { |_, hsh| hsh.empty? }
      @vtx.keep_if { |v|
        @edge.key?(v) or @edge.values.any? { |hsh| hsh.key? v }
      }
      self
    end

    # check both directions; return any edge found
    def edge_between?(src, dest)
      @edge.dig(src, dest) or @edge.dig(dest, src)
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
      if src
        hsh = @edge[src] or return self
        if dest   # (src, dest, ?)
          if (e = hsh[dest])
            yield e unless (value and e.value != value)
          end
        else      # (src, _, ?)
          hsh.each_value { |e|
            yield e unless (value and e.value != value)
          }
        end
      else        # (_, ?, ?)
        @edge.values.each { |hsh|
          if dest # (_, dest, ?)
            if (e = hsh[dest])
              yield e unless (value and e.value != value)
            end
          else    # (_, _, ?)
            hsh.each_value { |e|
              yield e unless (value and e.value != value)
            }
          end
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
      self.edges.join($/)
    end
  end

  # allow multiple edges between any two vertices
  # store edges with Array rather than Hash
  class MultiGraph < Graph
    # @edge[src] => [Edge, Edge, ...]
    def add_edge e
      @edge[e.src] ||= []
      @edge[e.src] << e
      @vtx.add(e.src)
      @vtx.add(e.dest)
      e
    end

    def delete(edge)
      @edge.each { |src, ary| ary.delete_if { |e| e == edge } }
      self
    end

    def clear!(src: nil, dest: nil, value: nil)
      if src
        ary = @edge[src] or return
        if dest         # (src, dest, ?)
          ary.delete_if { |e|
            e.dest == dest and (value.nil? or e.value == value)
          }
        else            # (src, _, ?)
          if value.nil? # (src, _, _)
            @edge.delete(src)
          else          # (src, _, value)
            ary.delete_if { |e| e.value == value }
          end
        end
      else                                         # (_, ?, ?)
        @edge.each_value { |ary|
          ary.delete_if { |e|
            (dest.nil? and value.nil?) or          # (_, _, _)
              (dest.nil? and e.value == value) or  # (_, _, value)
              (value.nil? and e.dest == dest) or   # (_, dest, _)
              (e.dest == dest and e.value == value)# (_, dest, value)
          }
        }
      end
    end

    def clean!
      @edge.delete_if { |_, ary| ary.empty? }
      @vtx.keep_if { |v| @edge.key?(v) or !self.edges(dest: v).empty? }
      self
    end

    # check both directions; return any edge found
    def edge_between?(src, dest)
      @edge[src].each { |e| return e if e.dest == dest } if @edge[src]
      @edge[dest].each { |e| return e if e.dest == src } if @edge[dest]
      false
    end

    # return the (dest) vertex for an edge matching (src, value)
    def follow(src, value)
      ary = @edge[src] or return false
      dests = ary.select { |e| e.value == value }.map(&:dest)
      return false if dests.empty?
      dests.sample
    end

    # iterate edges like: graph.each_edge(**filters) { |e| puts e }
    def each_edge(src: nil, dest: nil, value: nil)
      if src
        ary = @edge[src] or return self      # filter on src
        ary.each { |e|
          next if dest and e.dest != dest    # filter on dest
          next if value and e.value != value # filter on value
          yield e
        }
      else
        @edge.values.each { |ary|
          ary.each { |e|
            next if dest and e.dest != dest    # filter on dest
            next if value and e.value != value # filter on value
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
        begin
          self.check_cycle!
        rescue CycleError => error
          @edge[e.src].delete(e.dest)
          raise error
        end
      end
      @vtx.add(e.src)
      @vtx.add(e.dest)
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search
      @vtx.each { |v| self.dfs v }
      self.reset_search
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

  class AcyclicMultiGraph < MultiGraph
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
        begin
          self.check_cycle!
        rescue CycleError => error
          @edge[e.src].delete(e.dest)
          raise error
        end
      end
      @vtx.add(e.src)
      @vtx.add(e.dest)
      e
    end

    # perform depth first search from every vertex; may raise CycleError
    def check_cycle!
      self.reset_search
      @vtx.each { |v| self.dfs v }
      self.reset_search
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

  # TODO
  class DirectedAcyclicMultiGraph < AcyclicMultiGraph; end

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
      self.reset_search
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

  # Pre-made patterns
  # Note: these are available for Graph and all its subclasses (self.new)
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
      #   __a__                 Graph: MultiGraphError
      #  /     \           MultiGraph: allow
      # 0       1        AcyclicGraph: MultiGraphError
      #  \__b__/                  DAG: MultiGraphError
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
      #  /     \         AcyclicGraph: CycleError
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
      #  \                        FSM: allow
      #  a\         Deterministic FSM: reject 2nd edge
      #    \
      #     2
      graph = self.new
      graph.edge 0, 1, :a
      graph.edge 0, 2, :a
      graph
    end

    # two separate trees
    def self.forest
      graph = self.new
      graph.edge 0, 1, :root
      graph.edge 1, 2, :trunk
      graph.edge 2, 3, :branch
      graph.edge 2, 4, :branch

      graph.edge 5, 6, :root
      graph.edge 6, 7, :trunk
      graph.edge 7, 8, :branch
      graph.edge 7, 9, :branch
      graph
    end

    # one center vertex; the rest are leaves
    def self.star
      graph = self.new
      graph.edge 0, 1, :center
      graph.edge 0, 2, :center
      graph.edge 0, 3, :center
      graph.edge 0, 4, :center
      graph.edge 0, 5, :center
      graph
    end

    # allows chains, not just leaves
    def self.starlike
      graph = self.new
      graph.edge 0, 1, :center
      graph.edge 0, 2, :center
      graph.edge 0, 3, :center
      graph.edge 0, 4, :center
      graph.edge 0, 5, :center
      graph.edge 5, 6, :ray
      graph
    end

    # all vertices within distance 1 of a central path subgraph
    def self.caterpillar
      graph = self.new
      graph.edge 0, 1, :head
      graph.edge 1, 2, :trunk
      graph.edge 2, 3, :trunk
      graph.edge 3, 4, :trunk
      graph.edge 4, 5, :tail
      graph.edge 1, 6, :leg
      graph.edge 1, 7, :leg
      graph.edge 2, 8, :leg
      graph.edge 2, 9, :leg
      graph.edge 3, 10, :leg
      graph.edge 3, 11, :leg
      graph.edge 4, 12, :leg
      graph.edge 4, 13, :leg
      graph
    end

    # all vertices within distance 1 of a central path subgraph
    def self.lobster
      graph = self.caterpillar
      graph.edge 6, 14, :claw
      graph.edge 6, 15, :claw
      graph.edge 7, 16, :claw
      graph.edge 7, 17, :claw
      graph
    end
  end
end
