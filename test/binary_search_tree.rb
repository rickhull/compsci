require 'compsci/node'
require 'compsci/binary_search_tree'
require 'compsci/names'
require 'minitest/autorun'

include CompSci

describe BinarySearchTree do
  before do
    @keys = Array.new(4) { |i| Names::WW2[i] }
    @values = Array.new(4) { Names::SOLAR.sample }
    @nodes = Array.new(4) { |i|
      KeyNode.new(@values[i], key: @keys[i], children: 2)
    }
    @tree = BinarySearchTree.new(@nodes.first)

    # tree will look like:
    # A:val1
    #  B:val2
    #   C:val3
    #    D:val4
  end

  it "must display_level" do
    str = BinarySearchTree.display_level nodes: @nodes, width: 80
    str.size.must_be :>=, 80  # it can overflow

    str = BinarySearchTree.display_level nodes: @nodes, width: 200
    str.size.must_equal 200   # it won't overflow

    @keys.each { |k| str.must_include k.to_s }
    @values.each { |v| str.must_include v.to_s }
  end

  it "must provide a new node" do
    node = BinarySearchTree.node('the key', 'the value')
    node.must_be_kind_of Node
    node.must_be_kind_of KeyNode
    node.key.must_equal 'the key'
    node.value.must_equal 'the value'
  end

  it "must instantiate with key and value" do
    tree = BinarySearchTree.create('the key', 'the value')
    node = tree.root
    node.must_be_kind_of Node
    node.must_be_kind_of KeyNode
    node.key.must_equal 'the key'
    node.value.must_equal 'the value'
  end

  it "must decide what to do with duplicate nodes" do
  end

  it "must decide what to do with duplicate keys" do
  end

  it "must insert nodes" do
    1.upto(@nodes.size - 1) { |i| @tree[@keys[i]] = @values[i] }
    @tree.root.children.wont_be_empty
    @tree.root.children[0].nil?.must_equal true
    @tree.root.children[1].key.must_equal @keys[1]
    @tree.root.children[1].children[0].nil?.must_equal true
    @tree.root.children[1].children[1].value.must_equal @values[2]
  end

  it "must search nodes" do
    tree = nil
    new_order = (0..9).to_a.shuffle
    new_order.each { |i|
      k, v = Names::NATO[i], Names::SOLAR.sample
      if tree.nil?
        tree = BinarySearchTree.create(k, v)
      else
        tree[k] = v
      end
    }

    2.times {
      key = Names::NATO[new_order.sample]
      node = tree.search_iterative key
      node.wont_be_nil
      node.key.must_equal key
    }

    2.times {
      key = Names::NATO[new_order.sample]
      node = tree.search_recursive key
      node.wont_be_nil
      node.key.must_equal key
    }

    tree.search_iterative(Names::SOLAR.sample).must_be_nil
    tree.search_recursive(Names::SOLAR.sample).must_be_nil
  end
end
