require 'minitest/autorun'
require 'compsci/graph'

include CompSci

describe Edge do
  before do
    @v0 = 0
    @v1 = 1
    @e = Edge.new(@v0, @v1)
  end

  it "has src-vertex, dest-vertex, and value, possibly nil" do
    expect(@e.src).must_equal @v0
    expect(@e.dest).must_equal @v1
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
    @graph = Graph.new
  end

  it "accepts loop1, loop3" do
    expect(Graph.loop1).must_be_kind_of Graph
    expect(Graph.loop3).must_be_kind_of Graph
  end

  it "rejects loop2" do
    expect { Graph.loop2 }.must_raise Graph::MultiGraphError
  end

  it "accepts a diamond pattern" do
    graph = Graph.diamond
    expect(graph).must_be_kind_of Graph
    expect(graph.vtxs.count).must_equal 4
    expect(graph.edges.count).must_equal 4
  end

  it "doesn't allow a multigraph" do
    expect { Graph.multigraph }.must_raise Graph::MultiGraphError
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
    edges = @graph.edges
    expect(edges).must_be_kind_of Array
    expect(edges.count).must_equal 2

    # edges(src)
    from_0 = @graph.edges(src: 0)
    expect(@graph.edges(src: 3)).must_be_empty
    expect(from_0).must_be_kind_of Array
    expect(from_0.count).must_equal 1
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

  it "iterates over each edge, with filters" do
    graph = Graph.diamond

    # 4 edges to a diamond
    count = 0
    graph.each_edge { |e|
      expect(e).must_be_kind_of Edge
      count += 1
    }
    expect(count).must_equal 4

    # 2 edges from 0
    count = 0
    graph.each_edge(src: 0) { |e|
      expect(e.src).must_equal 0
      count += 1
    }
    expect(count).must_equal 2

    # 0 edges from 27
    count = 0
    graph.each_edge(src: 27) { |e|
      expect(true).must_equal false
      count += 1
    }
    expect(count).must_equal 0

    # 2 edges to 3
    count = 0
    graph.each_edge(dest: 3) { |e|
      expect(e.dest).must_equal 3
      count += 1
    }
    expect(count).must_equal 2

    # 0 edges from 0 to 3
    count = 0
    graph.each_edge(src: 0, dest: 3) { |e|
      expect(true).must_equal false
      count += 1
    }
    expect(count).must_equal 0

    # 1 edge with value :c
    count = 0
    graph.each_edge(value: :c) { |e|
      expect(e.value).must_equal :c
      count += 1
    }
    expect(count).must_equal 1
  end
end

describe MultiGraph do
  before do
    @graph = MultiGraph.new
  end

  it "accepts loop1, loop2, loop3" do
    expect(MultiGraph.loop1).must_be_kind_of MultiGraph
    expect(MultiGraph.loop2).must_be_kind_of MultiGraph
    expect(MultiGraph.loop3).must_be_kind_of MultiGraph
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

    # edges(src)
    from_0 = @graph.edges(src: 0)
    expect(@graph.edges(src: :does_not_exist)).must_be_empty
    expect(from_0).must_be_kind_of Array
    expect(from_0.count).must_equal 1
  end

  it "iterates over each edge, with filters" do
    graph = MultiGraph.diamond

    # 4 edges to a diamond
    count = 0
    graph.each_edge { |e|
      expect(e).must_be_kind_of Edge
      count += 1
    }
    expect(count).must_equal 4

    # 2 edges from 0
    count = 0
    graph.each_edge(src: 0) { |e|
      expect(e.src).must_equal 0
      count += 1
    }
    expect(count).must_equal 2

    # 0 edges from 27
    count = 0
    graph.each_edge(src: 27) { |e|
      expect(true).must_equal false
      count += 1
    }
    expect(count).must_equal 0

    # 2 edges to 3
    count = 0
    graph.each_edge(dest: 3) { |e|
      expect(e.dest).must_equal 3
      count += 1
    }
    expect(count).must_equal 2

    # 0 edges from 0 to 3
    count = 0
    graph.each_edge(src: 0, dest: 3) { |e|
      expect(true).must_equal false
      count += 1
    }
    expect(count).must_equal 0

    # 1 edge with value :c
    count = 0
    graph.each_edge(value: :c) { |e|
      expect(e.value).must_equal :c
      count += 1
    }
    expect(count).must_equal 1
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
    @graph = AcyclicGraph.new
  end

  it "rejects loop1, loop2, loop3" do
    expect { AcyclicGraph.loop1 }.must_raise Graph::CycleError
    expect { AcyclicGraph.loop2 }.must_raise Graph::MultiGraphError
    expect { AcyclicGraph.loop3.check_cycle! }.must_raise Graph::CycleError
  end

  it "rejects a diamond pattern" do
    ag = AcyclicGraph.diamond
    expect(ag).must_be_kind_of AcyclicGraph
    expect(ag.vtxs.count).must_equal 4
    expect(ag.edges.count).must_equal 4
    expect { ag.check_cycle! }.must_raise Graph::CycleError
  end

  it "doesn't allow a multigraph" do
    expect { AcyclicGraph.multigraph }.must_raise Graph::MultiGraphError
  end

  it "allows a fork pattern" do
    graph = AcyclicGraph.fork
    expect(graph).must_be_kind_of AcyclicGraph
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "rejects with check_add" do
    expect(@graph).must_be_kind_of AcyclicGraph
    @graph.check_add = true

    # create 3 edges, a-c
    @graph.edge(0, 1, :a)
    @graph.edge(0, 2, :b)
    @graph.edge(1, 3, :c)

    # edge d creates a loop (undirected edges)
    expect { @graph.edge(2, 3, :d) }.must_raise Graph::CycleError
  end

  it "has a multiline string representation" do
    expect(@graph).must_be_kind_of AcyclicGraph

    @graph.edge(0, 1, :a)
    @graph.edge(0, 2, :b)
    @graph.edge(1, 3, :c)

    edge_count = 3
    expect(@graph.edges.count).must_equal edge_count

    str = @graph.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end

describe DAG do
  before do
    @dag = DAG.new
  end

  it "rejects loop1, loop2, loop3" do
    expect { DAG.loop1 }.must_raise Graph::CycleError
    expect { DAG.loop2 }.must_raise Graph::MultiGraphError
    expect { DAG.loop3.check_cycle! }.must_raise Graph::CycleError
  end

  it "rejects a self-looping edge" do
    expect(@dag).must_be_kind_of DAG
    expect { @dag.edge(0, 0, "loop") }.must_raise Graph::CycleError
  end

  it "allows a diamond pattern" do
    dag = DAG.diamond
    expect(dag).must_be_kind_of DAG
    expect(dag.vtxs.count).must_equal 4
    expect(dag.edges.count).must_equal 4
    dag.check_cycle! # wont_raise
  end

  it "doesn't allow a multigraph" do
    expect { DAG.multigraph }.must_raise Graph::MultiGraphError
  end

  it "allows a fork pattern" do
    graph = DAG.fork
    expect(graph).must_be_kind_of DAG
    expect(graph.vtxs.count).must_equal 3
    expect(graph.edges.count).must_equal 2
  end

  it "rejects a directed loop" do
    expect(@dag).must_be_kind_of DAG

    # create 4 edges, a-d
    @dag.edge(0, 1, :a)
    @dag.edge(1, 2, :b)
    @dag.edge(2, 3, :c)
    @dag.edge(3, 0, :d)

    expect { @dag.check_cycle! }.must_raise Graph::CycleError
  end

  it "has a multiline string representation" do
    dag = DAG.diamond
    expect(dag.vtxs.count).must_equal 4
    edge_count = 4
    expect(dag.edges.count).must_equal edge_count
    str = dag.to_s
    expect(str).must_include NEWLINE
    expect(str.lines.count).must_equal edge_count
  end
end
