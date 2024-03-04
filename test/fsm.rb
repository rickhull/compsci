require 'minitest/autorun'
require 'compsci/fsm'

include CompSci

describe FiniteStateMachine do
  parallelize_me!

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

  it "has states and transitions between the states" do
    @fsm.transition('Locked', 'Locked', 'Push')
    @fsm.transition('Locked', 'Unlocked', 'Coin')
    @fsm.transition('Unlocked', 'Unlocked', 'Coin')
    @fsm.transition('Unlocked', 'Locked', 'Push')

    state = @fsm.walk('Coin', 'Push', 'Coin')
    expect(state).must_equal 'Unlocked'
    state = @fsm.walk('Push', 'Push', 'Push')
    expect(state).must_equal 'Locked'
  end

  it "can have multiple transitions between two states" do
    @fsm.transition(:locked, :unlocked, :key)
    @fsm.transition(:locked, :unlocked, :master_key)

    state = @fsm.walk(:key)
    expect(state).must_equal :unlocked
    state = @fsm.walk(:master_key)
    expect(state).must_equal :unlocked
  end

  it "can reject nondeterminism when transitions are added" do
    @fsm.check_add = true
    @fsm.transition(:a, :b, :input)
    expect { @fsm.transition(:a, :c, :input) }.must_raise DeterministicError

    @fsm.check_add = false
    @fsm.transition(:a, :c, :input)

    state = @fsm.walk(:input)
    expect([:b, :c]).must_include state
  end

  it "can reject nondeterminism when transitions are followed" do
    @fsm.check_add = false
    @fsm.check_follow = true
    @fsm.transition(:a, :b, :input)
    @fsm.transition(:a, :c, :input)
    expect { @fsm.walk(:input) }.must_raise DeterministicError

    @fsm.check_follow = false
    state = @fsm.walk(:input)
    expect([:b, :c]).must_include state
  end
end

describe DAFSAcceptor do
  before do
    @dafsa = DAFSAcceptor.new
  end

  it "can reject nondeterminism when transitions are added" do
    @dafsa.check_add = true
    @dafsa.transition(0, :a)
    expect { @dafsa.transition(0, :a) }.must_raise DeterministicError

    @dafsa.check_add = false
    @dafsa.transition(0, :a)
    expect(@dafsa).must_be_kind_of DAFSAcceptor
  end

  it "can reject nondeterminism when transitions are followed" do
    @dafsa.check_add = false
    @dafsa.check_follow = true
    @dafsa.transition(0, :a)
    @dafsa.transition(0, :a)
    expect { @dafsa.follow(0, :a) }.must_raise DeterministicError

    @dafsa.check_follow = false
    state = @dafsa.follow(0, :a)
    expect(state).wont_be_nil
    expect(state).wont_equal 0
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
