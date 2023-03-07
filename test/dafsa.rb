require 'minitest/autorun'
require 'compsci/dag'

include CompSci

describe DAFSAcceptor do
  before do
    @d = DAFSAcceptor.new
  end

  it "can encode: 'june'" do
    expect(@d).must_be_kind_of DAFSAcceptor

    cursor = @d.first
    %w[j u n e].each { |chr|
      cursor = @d.add_state(cursor, chr)
    }
    @d.final = cursor

    expect(@d.states.count).must_equal 5 # 'june' is stored on the edges

    # any initial edges ('j', here)
    hsh = @d.dag.edge[@d.first]
    expect(hsh).wont_be_nil
    expect(hsh.size).must_equal 1
    expect(hsh.values.first.value).must_equal 'j'
  end

  it "can accept: 'june'" do
    expect(@d).must_be_kind_of DAFSAcceptor

    cursor = @d.first
    %w[j u n e].each { |chr|
      cursor = @d.add_state(cursor, chr)
    }
    @d.final = cursor

    expect(@d.states.count).must_equal 5 # 'june' is stored on the edges

    expect(@d.accept?('july')).must_equal false
    expect(@d.accept?('june')).must_equal true
  end
end
