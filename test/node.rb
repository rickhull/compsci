require 'compsci/node'
require 'minitest/autorun'

include CompSci

describe Node do
  before do
    @martin_sheen = Node.new 'martin'
    @charlie_sheen = Node.new 'charlie'
    @emilio_estevez = Node.new 'emilio'
  end

  it "must start with no children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.children.must_be_empty
    }
  end

  it "must not respond to :parent" do
    @martin_sheen.respond_to?(:parent).must_equal false
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

describe ChildNode do
  before do
    @martin_sheen = ChildNode.new 'martin'
    @charlie_sheen = ChildNode.new 'charlie'
    @emilio_estevez = ChildNode.new 'emilio'
  end

  it "must start with neither parent nor children" do
    [@martin_sheen, @charlie_sheen, @emilio_estevez].each { |n|
      n.parent.nil?.must_equal true
      n.children.must_be_empty
    }
  end

  it "must track parent and children" do
    @charlie_sheen.set_parent(0, @martin_sheen)
    @charlie_sheen.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.set_child(0, @emilio_estevez)
    @martin_sheen.children.must_include @emilio_estevez
    @emilio_estevez.parent.must_equal @martin_sheen
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
