require 'minitest/autorun'
require 'compsci/fsm'

include CompSci

describe FiniteStateMachine do
  before do
    @fsm = FSM.new
  end

  it "can have multiple transitions between two states" do
    @fsm.transition(:locked, :unlocked, :key)
    @fsm.transition(:locked, :unlocked, :master_key)
    expect(@fsm).must_be_kind_of FSM
  end

  it "can have transitions to different states with the same input" do
    @fsm.transition('Locked', 'Unlocked', 'Coin')
    @fsm.transition('Locked', 'Unlatched', 'Coin')
    expect(@fsm).must_be_kind_of FSM
  end
end

describe DeterministicFiniteStateMachine do
  before do
    @fsm = DFSM.new
  end

  it "can have multiple transitions between two states" do
    @fsm.transition(:locked, :unlocked, :key)
    @fsm.transition(:locked, :unlocked, :master_key)
    expect(@fsm).must_be_kind_of FSM
  end

  it "has states and transitions between the states" do
    @fsm.transition('Locked', 'Locked', 'Push')
    @fsm.transition('Locked', 'Unlocked', 'Coin')
    @fsm.transition('Unlocked', 'Unlocked', 'Coin')
    @fsm.transition('Unlocked', 'Locked', 'Push')
    expect(@fsm).must_be_kind_of DFSM
  end

  it "rejects nondeterminism" do
    @fsm.transition(:a, :b, :input)
    expect {
      @fsm.transition(:a, :c, :input)
    }.must_raise DeterministicError
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
