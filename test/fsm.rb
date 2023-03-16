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
      @fsm.transition('Locked', 'Locked', 'Push')
      @fsm.transition('Locked', 'Unlocked', 'Coin')
      @fsm.transition('Unlocked', 'Unlocked', 'Coin')
      @fsm.transition('Unlocked', 'Locked', 'Push')
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
      @fsm.transition('Locked', 'Unlocked', 'Coin')
      @fsm.transition('Locked', 'Unlatched', 'Key')
      expect(@fsm).must_be_kind_of FSM
    end
  end
end

describe DAFSAcceptor do
  before do
    @dafsa = DAFSAcceptor.new
  end

  it "encodes 'june'" do
    expect(@dafsa).must_be_kind_of DAFSAcceptor
    @dafsa.encode('june')
    expect(@dafsa.graph.edges.count).must_equal 4
  end

  it "accepts: 'june'" do
    expect(@dafsa).must_be_kind_of DAFSAcceptor
    @dafsa.encode('june')

    expect(@dafsa.accept?('july')).must_equal false
    expect(@dafsa.accept?('june')).must_equal true
  end

  it "recognizes: march may june july" do
    expect(@dafsa).must_be_kind_of DAFSAcceptor
    trimester = %w[march may june july].sort
    calendar  = %w[january february march may june
                   july august september october november]
    trimester.each { |good_month| @dafsa.encode good_month }
    calendar.each { |month|
      expect(@dafsa.accept? month).must_equal trimester.include? month
    }
  end
end
