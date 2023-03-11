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
    (0..3).each { |i| @graph.v i }
  end

  it "accepts a self-looping edge" do
    expect(@graph).must_be_kind_of Graph
    expect(@graph.vtxs.count).must_equal 4

    vtx = @graph.vtxs[0]
    @graph.e(vtx, vtx, "loop") # wont_raise
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

  it "provides an array of edges" do
    @graph.e(@graph.vtxs[0], @graph.vtxs[1], :a)
    @graph.e(@graph.vtxs[1], @graph.vtxs[2], :b)
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
end

describe MultiGraph do
  before do
    # create 4 vertices, 0-3
    @graph = MultiGraph.new
    (0..3).each { |i| @graph.v i }
  end

  it "accepts a self-looping edge" do
    expect(@graph).must_be_kind_of MultiGraph
    expect(@graph.vtxs.count).must_equal 4

    vtx = @graph.vtxs[0]
    @graph.e(vtx, vtx, "loop") # wont_raise
  end

  it "accepts a diamond pattern" do
    graph = Graph.diamond
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 4
    expect(graph.edges.count).must_equal 4
  end

  it "accepts a multigraph" do
    graph = MultiGraph.multigraph
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 2
    expect(graph.edges.count).must_equal 2
  end

  it "provides an array of edges" do
    @graph.e(@graph.vtxs[0], @graph.vtxs[1], :a)
    @graph.e(@graph.vtxs[1], @graph.vtxs[2], :b)
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
end

describe AcyclicGraph do
  before do
    # create 4 vertices, 0-3
    @graph = AcyclicGraph.new
    (0..3).each { |i| @graph.v i }
  end

  it "rejects a self-looping edge" do
    expect(@graph).must_be_kind_of AcyclicGraph
    expect(@graph.vtxs.count).must_equal 4

    vtx = @graph.vtxs[0]
    expect { @graph.e(vtx, vtx, "loop") }.must_raise CycleError
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

  it "rejects with check_add" do
    expect(@graph).must_be_kind_of AcyclicGraph
    expect(@graph.vtxs.count).must_equal 4

    @graph.check_add = true

    # create 3 edges, a-c
    av = @graph.vtxs
    @graph.e(av[0], av[1], :a)
    @graph.e(av[0], av[2], :b)
    @graph.e(av[1], av[3], :c)

    # edge d creates a loop (undirected edges)
    expect { @graph.e(av[2], av[3], :d) }.must_raise CycleError
  end
end

describe DAG do
  before do
    # create 4 vertices, 0-3
    @dag = DAG.new
    (0..3).each { |i| @dag.v i }
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

  it "rejects a self-looping edge" do
    expect(@dag).must_be_kind_of DAG
    expect(@dag.vtxs.count).must_equal 4

    vtx = @dag.vtxs[0]
    expect { @dag.e(vtx, vtx, "loop") }.must_raise CycleError
  end

  it "rejects a directed loop" do
    expect(@dag).must_be_kind_of DAG
    expect(@dag.vtxs.count).must_equal 4

    # create 4 edges, a-d
    v = @dag.vtxs
    @dag.e(v[0], v[1], :a)
    @dag.e(v[1], v[2], :b)
    @dag.e(v[2], v[3], :c)
    @dag.e(v[3], v[0], :d)

    expect { @dag.check_cycle! }.must_raise CycleError
  end

  it "has a multiline string representation" do
    dag = DAG.diamond
    expect(dag.vtxs.count).must_equal 4
    expect(dag.edges.count).must_equal 4
    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    expect(dag.to_s).must_include NEWLINE
    expect(dag.to_s.lines.count).must_equal 4
  end
end
