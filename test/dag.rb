require 'minitest/autorun'
require 'compsci/dag'

include CompSci

describe Vertex do
  it "initializes with contents, possibly nil" do
    expect(Vertex.new.contents).must_be_nil
    expect(Vertex.new(0).contents).must_equal 0
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

  it "has from-vertex, to-vertex, and contents, possibly nil" do
    expect(@e.from).must_equal @v0
    expect(@e.to).must_equal @v1
    expect(@e.contents).must_be_nil

    e = Edge.new(@v0, @v1, :hello_world)
    expect(e.contents).must_equal :hello_world
  end

  it "has a string representation" do
    expect(@e.to_s).must_be_kind_of String
    expect(@e.to_s.length).must_be :>, 0
    expect(Edge.new(@v0, @v1, :hello_world).to_s).must_be_kind_of String
  end
end

describe AcyclicGraph do
  before do
    # create 4 vertices, 0-3
    @ag = AcyclicGraph.new
    (0..3).each { |i| @ag.v i }
  end

  it "rejects a self-looping edge" do
    expect(@ag).must_be_kind_of AcyclicGraph
    expect(@ag.vtxs.count).must_equal 4

    vtx = @ag.vtxs[0]
    expect { @ag.e(vtx, vtx, "loop") }.must_raise CycleError
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
    expect(@ag).must_be_kind_of AcyclicGraph
    expect(@ag.vtxs.count).must_equal 4

    @ag.check_add = true

    # create 3 edges, a-d
    av = @ag.vtxs
    @ag.e(av[0], av[1], :a)
    @ag.e(av[0], av[2], :b)
    @ag.e(av[1], av[3], :c)

    # the 4th edge creates a loop
    expect { @ag.e(av[2], av[3], :d) }.must_raise CycleError
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
    expect(dag.to_s).must_include "\n"
    expect(dag.to_s.lines.count).must_equal 4
  end
end
