require 'compsci/flex_node'
require 'minitest/autorun'

include CompSci

describe FlexNode do
  parallelize_me!

  before do
    @martin_sheen = FlexNode.new 'martin'
    @charlie_sheen = FlexNode.new 'charlie'
    @emilio_estevez = FlexNode.new 'emilio'
  end

  it "must track children" do
    @charlie_sheen.add_parent(@martin_sheen)
    expect(@martin_sheen.children).must_include @charlie_sheen
    expect(@martin_sheen.children).wont_include @emilio_estevez

    @martin_sheen.add_child @emilio_estevez
    expect(@martin_sheen.children).must_include @emilio_estevez
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    expect(@martin_sheen.children.size).must_equal 1
    expect(@martin_sheen.children.first.value).must_equal 'fake_emilio'
    expect(@martin_sheen.children).wont_include @emilio_estevez
  end

  it "does depth-first search" do
    vals = (0..30).to_a
    root = FlexNode.new vals.shift
    root.new_child vals.shift
    root.new_child vals.shift
    root.children.each { |c|
      c.new_child vals.shift
      c.new_child vals.shift

        c.children.each { |cc|
          cc.new_child vals.shift
          cc.new_child vals.shift
        }
    }

    visited = []
    root.df_search { |n|
      visited << n.value
      false
    }
    expect(visited).wont_be_empty
    expect(visited).must_equal [0, 1, 3, 5, 6, 4, 7, 8, 2, 9, 11, 12, 10, 13, 14]
  end

  it "does breadth-first search" do
    vals = (0..30).to_a
    root = FlexNode.new vals.shift
    root.new_child vals.shift
    root.new_child vals.shift
    root.children.each { |c|
      c.new_child vals.shift
      c.new_child vals.shift

      c.children.each { |cc|
        cc.new_child vals.shift
        cc.new_child vals.shift
      }
    }

    visited = []
    root.bf_search { |n|
      visited << n.value
      false
    }
    expect(visited).wont_be_empty
    expect(visited).must_equal [0, 1, 2, 3, 4, 9, 10, 5, 6, 7, 8, 11, 12, 13, 14]
  end

  describe "Binary FlexNode" do
    before do
      @root = FlexNode.new 100
      @child_slots = 2
    end

    it "must have an open parent" do
      expect(@root.open_parent?(@child_slots)).must_equal true
      expect(@root.open_parent(@child_slots)).must_equal @root
    end

    it "must push a value onto an open parent" do
      opc = @root.open_parent(@child_slots).children.size
      @root.push 27, @child_slots
      expect(@root.open_parent(@child_slots).children.size).must_equal opc + 1
    end

    it "must display properly via @root" do
      item_count = 31
      # tree already has a root node
      (item_count - 1).times { @root.push(rand(99), @child_slots) }
      str = @root.display
      line_count = str.split(NEWLINE).size
      expect(line_count).must_equal Math.log(item_count + 1, 2).ceil
    end

    describe "searching" do
      before do
        @root = FlexNode.new 42
        @child_slots = 2
        99.times { |i| @root.push(i, @child_slots) }
      end

      it "must find 42 quickly" do
        count = 0
        expect(@root.df_search { |n|
          count += 1
          n.value == 42
        }).must_equal @root
        expect(count).must_equal 1

        count = 0
        expect(@root.bf_search { |n|
          count += 1
          n.value == 42
        }).must_equal @root
        expect(count).must_equal 1
      end

      it "must find 99 slowly" do
        count = 0
        @root.df_search { |n|
          count += 1
          n.value == 99
        }
        expect(count).must_equal 100

        count = 0
        @root.bf_search { |n|
          count += 1
          n.value == 99
        }
        expect(count).must_equal 100
      end

      it "must find 81 accordingly" do
        count = 0
        @root.df_search { |n|
          count += 1
          n.value == 81
        }
        expect(count).must_equal 42

        count = 0
        @root.bf_search { |n|
          count += 1
          n.value == 81
        }
        expect(count).must_equal 83
      end
    end
  end
end




describe ChildFlexNode do
  parallelize_me!

  before do
    @martin_sheen = ChildFlexNode.new 'martin'
    @charlie_sheen = ChildFlexNode.new 'charlie'
    @emilio_estevez = ChildFlexNode.new 'emilio'
  end

  it "must track parent and children" do
    @charlie_sheen.add_parent(@martin_sheen)
    expect(@charlie_sheen.parent).must_equal @martin_sheen
    expect(@martin_sheen.children).must_include @charlie_sheen
    expect(@martin_sheen.children).wont_include @emilio_estevez

    @martin_sheen.add_child @emilio_estevez
    expect(@martin_sheen.children).must_include @emilio_estevez
    expect(@emilio_estevez.parent).must_equal @martin_sheen
  end

  it "must determine a node's generation" do
    expect(@emilio_estevez.gen).must_equal 0
    @martin_sheen.add_child @emilio_estevez
    expect(@emilio_estevez.gen).must_equal 1
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    expect(@martin_sheen.children.size).must_equal 1
    expect(@martin_sheen.children.first.value).must_equal 'fake_emilio'
    expect(@martin_sheen.children).wont_include @emilio_estevez
  end

  it "must recognize siblings" do
    @charlie_sheen.add_parent @martin_sheen
    @emilio_estevez.add_parent @martin_sheen
    @martin_sheen.new_child 'fake_emilio'

    expect(@charlie_sheen.siblings).must_include @emilio_estevez
    expect(@charlie_sheen.siblings).wont_include @martin_sheen
    expect(@emilio_estevez.siblings).must_include @charlie_sheen
    expect(@martin_sheen.siblings).must_be_empty
    expect(@emilio_estevez.siblings.find { |n|
             n.value == 'fake_emilio'
           }).wont_be_nil
  end

  describe "Quaternary ChildFlexNode" do
    before do
      @root = ChildFlexNode.new 42
      @child_slots = 4
    end

    it "must have an open parent" do
      expect(@root.open_parent?(@child_slots)).must_equal true
      expect(@root.open_parent(@child_slots)).must_equal @root
    end

    it "must push a value onto an open parent" do
      opc = @root.open_parent(@child_slots).children.size
      @root.push 27, @child_slots
      expect(@root.open_parent(@child_slots).children.size).must_equal opc + 1
    end
  end
end
