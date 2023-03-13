require 'minitest/autorun'
require 'compsci/fsm'

include CompSci

describe FiniteStateMachine do
  describe "Deterministic FSM" do
    before do
      @fsm = FSM.new
    end

    it "has an attr for determinism" do
      expect(@fsm.deterministic).must_equal true
    end

    it "has a graph, not a multigraph" do
      expect(@fsm.graph).must_be_kind_of Graph
      expect(@fsm.graph).wont_be_kind_of MultiGraph
    end

    it "has states and transitions between the states" do
      locked = @fsm.add_state 'Locked', initial: true
      expect(@fsm.initial).must_equal locked
      @fsm.add_state 'Unlocked'

      @fsm.add_transition('Locked', 'Locked', 'Push')
      @fsm.add_transition('Locked', 'Unlocked', 'Coin')
      @fsm.add_transition('Unlocked', 'Unlocked', 'Coin')
      @fsm.add_transition('Unlocked', 'Locked', 'Push')

      expect(@fsm).must_be_kind_of FSM
    end
  end

  describe "NonDeterministic FSM" do
    before do
      @fsm = FSM.new(deterministic: false)
    end

    it "has an attr for determinism" do
      expect(@fsm.deterministic).must_equal false
    end

    it "has a multigraph" do
      expect(@fsm.graph).must_be_kind_of MultiGraph
    end

    it "can have transitions to different states with the same input" do
      locked = @fsm.initial_state('Locked')
    end
  end
end

describe DAFSAcceptor do
  before do
    @d = DAFSAcceptor.new
  end

  it "can encode: 'june'" do
    expect(@d).must_be_kind_of DAFSAcceptor

    skip

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

    skip

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
