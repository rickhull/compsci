require 'minitest/autorun'
require 'compsci/dag'

include CompSci

describe Vertex do
  it "initializes with value, possibly nil" do
    expect(Vertex.new.value).must_be_nil
    expect(Vertex.new(0).value).must_equal 0
  end

  it "has a string representation" do
    expect(Vertex.new.to_s).must_be_kind_of String
    expect(Vertex.new(0).to_s).must_be_kind_of String
  end
end

describe Edge do
  before do
    @v0 = Vertex.new(0)
    @v1 = Vertex.new(1)
    @e = Edge.new(@v0, @v1)
  end

  it "has from-vertex, to-vertex, and value, possibly nil" do
    expect(@e.from).must_equal @v0
    expect(@e.to).must_equal @v1
    expect(@e.value).must_be_nil

    e = Edge.new(@v0, @v1, :hello_world)
    expect(e.value).must_equal :hello_world
  end

  it "has a string representation" do
    expect(@e.to_s).must_be_kind_of String
    expect(@e.to_s.length).must_be :>, 0
    expect(Edge.new(@v0, @v1, :hello_world).to_s).must_be_kind_of String
  end
end

describe Graph do
  before do
    # create 4 vertices, 0-3
    @graph = Graph.new
    (0..3).each { |i| @graph.vertex i }
  end

  it "acceptss a self-looping edge" do
    expect(@graph).must_be_kind_of Graph
    expect(@graph.vtxs.count).must_equal 4
    @graph.edge(0, 0, "loop") # wont_raise
  end

  it "accepts a diamond pattern" do
    graph = Graph.diamond
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 4
    expect(graph.edges.count).must_equal 4
  end

  it "doesn't allow a multigraph" do
    graph = Graph.multigraph
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 2
    # the second edge has overwritten the first
    expect(graph.edges.count).must_equal 1
  end

  it "allows a fork pattern" do
    graph = Graph.fork
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "provides an array of edges" do
    @graph.edge(0, 1, :a)
    @graph.edge(1, 2, :b)
    expect(@graph.edges).must_be_kind_of Array
    expect(@graph.edges.count).must_equal 2

    # edges(from)
    from_0 = @graph.edges(@graph.vtxs[0])
    from_3 = @graph.edges(@graph.vtxs[3])
    expect(from_0).must_be_kind_of Array
    expect(from_0.count).must_equal 1
    expect(from_3).must_be_kind_of Array
    expect(from_3).must_be_empty
  end

  it "has a multiline string representation" do
    graph = Graph.diamond
    expect(graph.vtxs.count).must_equal 4
    edge_count = 4
    expect(graph.edges.count).must_equal edge_count

    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    str = graph.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end

describe MultiGraph do
  before do
    # create 4 vertices, 0-3
    @graph = MultiGraph.new
    (0..3).each { |i| @graph.vertex i }
  end

  it "accepts a self-looping edge" do
    expect(@graph).must_be_kind_of MultiGraph
    expect(@graph.vtxs.count).must_equal 4
    @graph.edge(0, 0, "loop") # wont_raise
  end

  it "accepts a diamond pattern" do
    graph = MultiGraph.diamond
    expect(graph).must_be_kind_of MultiGraph
    expect(graph.vtxs.count).must_equal 4
    expect(graph.edges.count).must_equal 4
  end

  it "accepts a multigraph" do
    graph = MultiGraph.multigraph
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 2
    expect(graph.edges.count).must_equal 2
  end

  it "allows a fork pattern" do
    graph = MultiGraph.fork
    expect(graph).must_be_kind_of MultiGraph
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "provides an array of edges" do
    @graph.edge(0, 1, :a)
    @graph.edge(1, 2, :b)
    expect(@graph.edges).must_be_kind_of Array
    expect(@graph.edges.count).must_equal 2

    # edges(from)
    from_0 = @graph.edges(@graph.vtxs[0])
    from_3 = @graph.edges(@graph.vtxs[3])
    expect(from_0).must_be_kind_of Array
    expect(from_0.count).must_equal 1
    expect(from_3).must_be_kind_of Array
    expect(from_3).must_be_empty
  end

  it "has a multiline string representation" do
    multi = MultiGraph.diamond
    expect(multi.vtxs.count).must_equal 4
    edge_count = 4
    expect(multi.edges.count).must_equal edge_count
    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    str = multi.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end

describe AcyclicGraph do
  before do
    # create 4 vertices, 0-3
    @graph = AcyclicGraph.new
    (0..3).each { |i| @graph.vertex i }
  end

  it "rejects a self-looping edge" do
    expect(@graph).must_be_kind_of AcyclicGraph
    expect(@graph.vtxs.count).must_equal 4
    expect { @graph.edge(0, 0, "loop") }.must_raise CycleError
  end

  it "rejects a diamond pattern" do
    ag = AcyclicGraph.diamond
    expect(ag).must_be_kind_of AcyclicGraph
    expect(ag.vtxs.count).must_equal 4
    expect(ag.edges.count).must_equal 4
    expect { ag.check_cycle! }.must_raise CycleError
  end

  it "doesn't allow a multigraph" do
    ag = AcyclicGraph.multigraph
    expect(ag).must_be_kind_of AcyclicGraph
    expect(ag.vtxs.count).must_equal 2

    # the second edge has overwritten the first
    expect(ag.edges.count).must_equal 1
    ag.check_cycle! # wont_raise
  end

  it "allows a fork pattern" do
    graph = AcyclicGraph.fork
    expect(graph).must_be_kind_of AcyclicGraph
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "rejects with check_add" do
    expect(@graph).must_be_kind_of AcyclicGraph
    expect(@graph.vtxs.count).must_equal 4

    @graph.check_add = true

    # create 3 edges, a-c
    @graph.edge(0, 1, :a)
    @graph.edge(0, 2, :b)
    @graph.edge(1, 3, :c)

    # edge d creates a loop (undirected edges)
    expect { @graph.edge(2, 3, :d) }.must_raise CycleError
  end

  it "has a multiline string representation" do
    expect(@graph).must_be_kind_of AcyclicGraph
    expect(@graph.vtxs.count).must_equal 4

    # create 3 edges, a-c
    av = @graph.vtxs
    @graph.edge(0, 1, :a)
    @graph.edge(0, 2, :b)
    @graph.edge(1, 3, :c)

    edge_count = 3

    expect(@graph.edges.count).must_equal edge_count
    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    str = @graph.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end

describe DAG do
  before do
    # create 4 vertices, 0-3
    @dag = DAG.new
    (0..3).each { |i| @dag.vertex i }
  end

  it "rejects a self-looping edge" do
    expect(@dag).must_be_kind_of DAG
    expect(@dag.vtxs.count).must_equal 4

    expect { @dag.edge(0, 0, "loop") }.must_raise CycleError
  end

  it "allows a diamond pattern" do
    dag = DAG.diamond
    expect(dag).must_be_kind_of DAG
    expect(dag.vtxs.count).must_equal 4
    expect(dag.edges.count).must_equal 4
    dag.check_cycle! # wont_raise
  end

  it "doesn't allow a multigraph" do
    dag = DAG.multigraph
    expect(dag).must_be_kind_of DAG
    expect(dag.vtxs.count).must_equal 2

    # the second edge has overwritten the first
    expect(dag.edges.count).must_equal 1
    dag.check_cycle! # wont_raise
  end

  it "allows a fork pattern" do
    graph = DAG.fork
    expect(graph).must_be_kind_of DAG
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "rejects a directed loop" do
    expect(@dag).must_be_kind_of DAG
    expect(@dag.vtxs.count).must_equal 4

    # create 4 edges, a-d
    v = @dag.vtxs
    @dag.edge(0, 1, :a)
    @dag.edge(1, 2, :b)
    @dag.edge(2, 3, :c)
    @dag.edge(3, 0, :d)

    expect { @dag.check_cycle! }.must_raise CycleError
  end

  it "has a multiline string representation" do
    dag = DAG.diamond
    expect(dag.vtxs.count).must_equal 4
    edge_count = 4
    expect(dag.edges.count).must_equal edge_count
    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    str = dag.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end
