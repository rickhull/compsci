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

  it "must track children" do
    @charlie_sheen.add_parent(@martin_sheen)
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
  end

  it "must not respond to :parent" do
    @martin_sheen.respond_to?(:parent).must_equal false
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
    @charlie_sheen.add_parent(@martin_sheen)
    @charlie_sheen.parent.must_equal @martin_sheen
    @martin_sheen.children.must_include @charlie_sheen

    @martin_sheen.children.wont_include @emilio_estevez
    @martin_sheen.add_child @emilio_estevez
    @martin_sheen.children.must_include @emilio_estevez
    @emilio_estevez.parent.must_equal @martin_sheen
  end

  it "must create children from scalars" do
    @martin_sheen.new_child 'fake_emilio'
    @martin_sheen.children.size.must_equal 1
    @martin_sheen.children.first.value.must_equal 'fake_emilio'
    @martin_sheen.children.wont_include @emilio_estevez
  end
end
