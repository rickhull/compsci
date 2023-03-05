require 'minitest/autorun'
require 'compsci/dag'

include CompSci

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
    expect { @ag.e(vtx, vtx, "loop") }.must_raise
  end

  it "rejects a diamond pattern" do
    expect(@ag).must_be_kind_of AcyclicGraph
    expect(@ag.vtxs.count).must_equal 4

    # create 4 edges, diamond pattern
    v = @ag.vtxs
    @ag.e(v[0], v[1], :a)
    @ag.e(v[0], v[2], :b)
    @ag.e(v[1], v[3], :c)
    @ag.e(v[2], v[3], :d)

    expect { @ag.check_cycle! }.must_raise
  end

  it "rejects with check_add" do
    expect(@ag).must_be_kind_of AcyclicGraph
    expect(@ag.vtxs.count).must_equal 4

    @ag.check_add = true

    # create 4 edges, a-d
    av = @ag.vtxs
    @ag.e(av[0], av[1], :a)
    @ag.e(av[0], av[2], :b)
    @ag.e(av[1], av[3], :c)

    expect { @ag.e(av[2], av[3], :d) }.must_raise
  end
end

describe DAG do
  def diamond
    dag = DAG.new
    (0..3).each { |i| dag.v i }
    # create 4 edges, a-d
    v = dag.vtxs
    dag.e(v[0], v[1], :a)
    dag.e(v[0], v[2], :b)
    dag.e(v[1], v[3], :c)
    dag.e(v[2], v[3], :d)
    dag
  end

  before do
    # create 4 vertices, 0-3
    @dag = DAG.new
    (0..3).each { |i| @dag.v i }
  end

  it "allows a diamond pattern" do
    dag = diamond()
    expect(dag).must_be_kind_of DAG
    expect(dag.vtxs.count).must_equal 4
    expect(dag.edges.count).must_equal 4
    dag.check_cycle! # wont_raise
  end

  it "rejects a self-looping edge" do
    expect(@dag).must_be_kind_of DAG
    expect(@dag.vtxs.count).must_equal 4

    vtx = @dag.vtxs[0]
    expect { @dag.e(vtx, vtx, "loop") }.must_raise
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

    expect { @dag.check_cycle! }.must_raise
  end

  it "has a multiline string representation" do
    dag = diamond()
    expect(dag.vtxs.count).must_equal 4
    expect(dag.edges.count).must_equal 4
    # since the edges have references to the vertices, we return multiple
    # lines of text, one for each edge
    expect(dag.to_s).must_include "\n"
    expect(dag.to_s.lines.count).must_equal 4
  end
end

describe Edge do
  before do
    @v0 = Vertex.new(0)
    @v1 = Vertex.new(1)
    @edge = Edge.new(@v0, @v1, :a)
  end

  it "has a string representation" do
    expect(@edge.to_s).must_be_kind_of String
    expect(@edge.to_s.length).must_be :>, 0
  end
end
