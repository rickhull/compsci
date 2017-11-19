require 'compsci/node'
require 'compsci/names'
require 'minitest/autorun'

include CompSci

describe Node do
  before do
    @martin_sheen = Node.new 'martin'
    @charlie_sheen = Node.new 'charlie'
    @emilio_estevez = Node.new 'emilio'
  end

  it "must display_line" do
    nodes = [@martin_sheen, @charlie_sheen, @emilio_estevez]
    str = Node.display_line nodes: nodes, width: 80
    # TODO: it was 78 once.  Why < 80?
    str.size.must_be :>=, 78  # it might overflow

    str = Node.display_line nodes: nodes, width: 200
    str.size.must_be :>=, 198   # it won't overflow
  end


  it "must start with no children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.children.compact.must_be_empty
    }
  end

  it "must not respond to :parent" do
    @martin_sheen.respond_to?(:parent).must_equal false
  end

  it "must create a tree by adding children" do
    @martin_sheen[0] = @charlie_sheen
    @martin_sheen[1] = @emilio_estevez
    @martin_sheen.children.must_include @charlie_sheen
    @martin_sheen.children.must_include @emilio_estevez
  end
end

describe KeyNode do
  before do
    @martin_sheen =   KeyNode.new 'martin',  key: 'marty'
    @charlie_sheen =  KeyNode.new 'charlie', key: 'charles'
    @emilio_estevez = KeyNode.new 'emilio',  key: 'emile'
  end

  it "must start with no children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.children.compact.must_be_empty
    }
  end

  it "must not respond to :parent" do
    @martin_sheen.respond_to?(:parent).must_equal false
  end

  it "must have a key" do
    @martin_sheen.key.must_equal 'marty'
    @charlie_sheen.key.must_equal 'charles'
    @emilio_estevez.key.must_equal 'emile'
  end

  describe "KeyNode.key_cmp_idx" do
    it "must handle 2 or 3 child_slots" do
      c2 = {
        [1,2]  => 0,
        [1,10] => 0,
        [2,2]  => :raise,
        [3,2]  => 1,
        [10,2] => 1,
      }
      c3 = {
        [1,2] => 0,
        [1,10] => 0,
        [2,2] => 1,
        [3,2] => 2,
        [10,2] => 2,
      }

      c2.each { |(new_key, key), expected|
        if expected == :raise
          proc {
            KeyNode.key_cmp_idx(new_key, key)
          }.must_raise KeyNode::DuplicateKey
        else
          KeyNode.key_cmp_idx(new_key, key).must_equal expected
        end
      }

      c3.each { |(new_key, key), expected|
        KeyNode.key_cmp_idx(new_key, key, child_slots: 3).must_equal expected
      }
    end
  end

  describe "Binary Search Tree" do
    before do
      @keys = Array.new(4) { |i| Names::WW2[i] }
      @values = Array.new(4) { Names::SOLAR.sample }
      @root = KeyNode.new(@values[0], key: @keys[0], children: 2)
      1.upto(@keys.size - 1) { |i| @root.insert(@keys[i], @values[i]) }

      # tree looks like:
      # A:val1
      #  B:val2
      #   C:val3
      #    D:val4
    end

    it "must link to inserted nodes" do
      @root.children.wont_be_empty
      @root.children[0].must_be_nil
      c1 = @root.children[1]
      c1.wont_be_nil
      c1.key.must_equal @keys[1]
      c1.children[0].must_be_nil
      cc1 = c1.children[1]
      cc1.wont_be_nil
      cc1.value.must_equal @values[2]
      cc1.children[0].must_be_nil
      ccc1 = cc1.children[1]
      ccc1.wont_be_nil
      ccc1.key.must_equal @keys[3]
      ccc1.value.must_equal @values[3]
    end

    it "must search nodes" do
      node = nil
      new_order = (0..9).to_a.shuffle
      new_order.each { |i|
        k, v = Names::NATO[i], Names::SOLAR.sample
        if node.nil?
          node = KeyNode.new(v, key: k, children: 2)
        else
          node.insert(k, v)
        end
      }

      3.times {
        key = Names::NATO[new_order.sample]
        found = node.search key
        found.wont_be_nil
        found.key.must_equal key
      }

      node.search(Names::SOLAR.sample).must_be_nil
    end

    it "must accept or reject duplicates" do
      proc {
        @root.insert(@keys[0], @values.sample)
      }.must_raise KeyNode::DuplicateKey

      node = KeyNode.new(@values[0], key: @keys[0], duplicates: true)
      child = node.insert(@keys[0], @values[0])
      child.must_be_kind_of KeyNode
      node.children[1].must_equal child
      node.children[0].must_be_nil
    end
  end

  describe "Ternary Search Tree" do
    before do
      @keys = Array.new(4) { |i| Names::NATO[i] }
      @values = Array.new(4) { Names::SOLAR.sample }
      @root = KeyNode.new(@values[0], key: @keys[0], children: 3)
      1.upto(@keys.size - 1) { |i| @root.insert(@keys[i], @values[i]) }

      # tree looks like:
      # A:val1
      #  B:val2
      #   C:val3
      #    D:val4
    end

    it "must insert a duplicate as the middle child" do
      node3 = KeyNode.new(@values[0], key: @keys[0], children: 3)
      child = node3.insert(@keys[0], @values[0])
      child.must_be_kind_of KeyNode
      node3.children[1].must_equal child
      node3.children[0].must_be_nil
      node3.children[2].must_be_nil
    end
  end
end

describe ChildNode do
  before do
    @martin_sheen = ChildNode.new 'martin'
    @charlie_sheen = ChildNode.new 'charlie'
    @emilio_estevez = ChildNode.new 'emilio'
  end

  it "must start with neither parent nor children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.parent.must_be_nil
      n.children.compact.must_be_empty
    }
  end

  it "must track parent and children" do
    @martin_sheen[0] = @charlie_sheen
    @charlie_sheen.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen[1] = @emilio_estevez
    @emilio_estevez.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @emilio_estevez
    @martin_sheen.children.must_include @charlie_sheen
  end

  it "must track siblings" do
    @martin_sheen[0] = @charlie_sheen
    @martin_sheen[1] = @emilio_estevez
    @charlie_sheen.siblings.must_include @emilio_estevez
    # TODO: should siblings not include self?
    # @charlie_sheen.siblings.wont_include @charlie_sheen
    @charlie_sheen.siblings.must_include @charlie_sheen
  end

  it "must track generation" do
    @martin_sheen[0] = @charlie_sheen
    @charlie_sheen.gen.must_equal 1
    @charlie_sheen[0] = @emilio_estevez # kinky!
    @emilio_estevez.gen.must_equal 2
  end
end

describe FlexNode do
  before do
    @martin_sheen = FlexNode.new 'martin'
    @charlie_sheen = FlexNode.new 'charlie'
    @emilio_estevez = FlexNode.new 'emilio'
  end

  it "must track children" do
    @charlie_sheen.add_parent(@martin_sheen)
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    @martin_sheen.children.size.must_equal 1
    @martin_sheen.children.first.value.must_equal 'fake_emilio'
    @martin_sheen.children.wont_include @emilio_estevez
  end
end

describe ChildFlexNode do
  before do
    @martin_sheen = ChildFlexNode.new 'martin'
    @charlie_sheen = ChildFlexNode.new 'charlie'
    @emilio_estevez = ChildFlexNode.new 'emilio'
  end

  it "must track parent and children" do
    @charlie_sheen.add_parent(@martin_sheen)
    @charlie_sheen.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
    @emilio_estevez.parent.must_equal @martin_sheen
  end

  it "must determine a node's generation" do
    @emilio_estevez.gen.must_equal 0
    @martin_sheen.add_child @emilio_estevez
    @emilio_estevez.gen.must_equal 1
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    @martin_sheen.children.size.must_equal 1
    @martin_sheen.children.first.value.must_equal 'fake_emilio'
    @martin_sheen.children.wont_include @emilio_estevez
  end

  it "must recognize siblings" do
    @charlie_sheen.add_parent @martin_sheen
    @emilio_estevez.add_parent @martin_sheen
    @martin_sheen.new_child 'fake_emilio'

    @charlie_sheen.siblings.must_include @emilio_estevez
    @charlie_sheen.siblings.wont_include @martin_sheen
    @emilio_estevez.siblings.must_include @charlie_sheen
    @martin_sheen.siblings.must_be_empty
    @emilio_estevez.siblings.find { |n| n.value == 'fake_emilio' }.wont_be_nil
  end
end
