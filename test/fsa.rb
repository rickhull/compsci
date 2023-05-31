require 'minitest/autorun'
require 'compsci/fsa'

include CompSci

describe State do
  before do
    @state = State.new(:foo)
  end

  describe "State.comparable!" do
    it "passes the value along if it's Comparable" do
      [0, :foo, 'asdf'].each { |value|
        expect(State.comparable!(value)).must_equal value
      }
    end

    it "raises TransitionError if it's not Comparable" do
      [Object.new, Array.new, Hash.new].each { |value|
        expect { State.comparable!(value) }.must_raise TransitionError
      }
    end
  end

  it "has a value" do
    expect(@state.value).must_equal :foo
  end

  describe "outbound transitions" do
    it "creates dest transitions" do
      dax = @state.new_dest(:transition, :dax)
      expect(dax).must_be_kind_of State
      expect(dax.value).must_equal :dax
      expect(@state.follow(:transition)).must_equal dax
    end

    it "updates src transition when dest is added" do
      dax = @state.new_dest(:transition, :dax)
      expect(dax).must_be_kind_of State
      expect(dax.value).must_equal :dax

      source = dax.retreat(:transition)
      expect(source).must_equal @state
      expect(source.value).must_equal :foo
    end

    it "can simply add dest States" do
      new_state = @state.add_dest(:transition, State.new(:bar))
      expect(@state.follow(:transition)).must_equal new_state

      # State#add_dest does not automatically update its src transition
      expect(new_state.retreat(:transition)).must_be_nil

      new_state = @state.add_dest!(:transition, State.new(:bar))
      expect(@state.follow(:transition)).must_equal new_state

      # State#add_dest! updates src transition for new_state
      expect(new_state.retreat(:transition)).must_equal @state
    end

    it "efficiently scans forward even in the presence of cycles" do
      cauchy = State.cauchy
      scanned = cauchy.scan
      expect(scanned.keys.count).must_equal 5
      expect([:asleep, :eating, :hiding,
              :litterbox, :playing]).must_include scanned.keys.sample.value

      turnstile = State.turnstile
      scanned = turnstile.scan
      expect(scanned.keys.count).must_equal 2
      expect([:unlocked, :locked]).must_include scanned.keys.sample.value
    end

    it "efficiently searches for State values" do
      cauchy = State.cauchy
      litterbox = cauchy.search(:litterbox)
      expect(litterbox).must_be_kind_of State
      expect(litterbox.value).must_equal :litterbox

      playing = cauchy.search(:playing)
      expect(playing).must_be_kind_of State
      expect(playing.value).must_equal :playing
    end
  end

  describe "inbound transitions" do
    it "creates src transitions" do
      sax = @state.new_src(:transition, :sax)
      expect(sax).must_be_kind_of State
      expect(sax.value).must_equal :sax
      expect(@state.retreat(:transition)).must_equal sax
    end

    it "updates dest transition when src is added" do
      sax = @state.new_src(:transition, :sax)
      expect(sax).must_be_kind_of State
      expect(sax.value).must_equal :sax

      source = sax.follow(:transition)
      expect(source).must_equal @state
      expect(source.value).must_equal :foo
    end

    it "can simply add src States" do
      new_state = @state.add_src(:transition, State.new(:bar))
      expect(@state.retreat(:transition)).must_equal new_state

      # State#add_src does not automatically update its dest transition
      expect(new_state.follow(:transition)).must_be_nil

      new_state = @state.add_src!(:transition, State.new(:bar))
      expect(@state.retreat(:transition)).must_equal new_state

      # State#add_dest! updates src transition for new_state
      expect(new_state.follow(:transition)).must_equal @state
    end

    it "efficiently reverse searches for State values" do
      cauchy = State.cauchy
      litterbox = cauchy.rsearch(:litterbox)
      expect(litterbox).must_be_kind_of State
      expect(litterbox.value).must_equal :litterbox

      playing = cauchy.rsearch(:playing)
      expect(playing).must_be_kind_of State
      expect(playing.value).must_equal :playing
    end
  end

  it "responds to #to_s and #inspect" do
    cauchy = State.cauchy
    str = cauchy.to_s
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str).must_include($/)

    str = cauchy.inspect
    expect(str).must_be_kind_of String
    expect(str).wont_be_empty
    expect(str).wont_include($/)
  end
end

describe FiniteStateAutomaton do
  before do
    @fsa = FSA.new(:initial)
  end

  it "chains a new state via a transition" do
    expect(@fsa.initial).must_be_kind_of State
    expect(@fsa.initial.value).must_equal :initial
    expect(@fsa.cursor).must_equal @fsa.initial

    @fsa.chain_state(:transition, :final)
    expect(@fsa.cursor).wont_equal @fsa.initial
    expect(@fsa.cursor).must_be_kind_of State
    expect(@fsa.cursor.value).must_equal :final

    @fsa.cursor = @fsa.initial
    expect(@fsa.cursor).must_equal @fsa.initial

    final = @fsa.follow(:transition)
    expect(final).must_be_kind_of State
    expect(final.value).must_equal :final
    expect(@fsa.cursor).must_equal final
  end

  it "can be created via explicit lists of transitions" do
    @fsa.transition(:initial, :start, 0)
    @fsa.transition(0, :a, 1)
    @fsa.transition(0, :b, 2)
    @fsa.transition(1, :c, 3)
    @fsa.transition(2, :d, 3)
    expect(@fsa.cursor.value).must_equal 3

    @fsa.scan
    expect(@fsa.states.count).must_equal 5
  end

  it "allows cycles" do
    expect(@fsa.initial).must_be_kind_of State
    expect(@fsa.initial.value).must_equal :initial
    expect(@fsa.cursor).must_equal @fsa.initial

    @fsa.chain_state(:out, :other)
    @fsa.chain_state(:back, :initial)
    expect(@fsa.cursor.value).must_equal :initial

    other = @fsa.follow(:out)
    expect(other.value).must_equal :other
    expect(@fsa.cursor).must_equal other

    @fsa.follow(:back)
    expect(@fsa.cursor.value).must_equal :initial
  end

  it "completes a scan in the presence of cycles" do
    @fsa.chain_state(:hop, :middle)
    @fsa.chain_state(:skip, :end)
    @fsa.chain_state(:jump, :middle)
    @fsa.chain_state(:slide, :initial)

    expect(@fsa.cursor.value).must_equal :initial

    @fsa.scan
    expect(@fsa.states.count).must_equal 3
    expect(@fsa.states.keys - [:initial, :middle, :end]).must_be_empty
  end

  it "has a settable cursor" do
    cauchy = FSA.cauchy
    cauchy.cursor = cauchy.initial
    expect(cauchy.cursor).must_equal cauchy.initial

    cauchy.next(:sample)
    expect(cauchy.cursor).wont_equal cauchy.initial
    tmp = cauchy.cursor

    cauchy.next(:first)
    expect(cauchy.cursor).wont_equal tmp
    tmp = cauchy.cursor

    cauchy.next(:last)
    expect(cauchy.cursor).wont_equal tmp
  end

  it "follows specific transitions" do
    cauchy = FSA.cauchy
    cauchy.scan
    expect(cauchy.initial.value).must_equal :asleep
    state = cauchy.follow(:food)
    expect(state.value).must_equal :eating
    expect(cauchy.cursor).must_equal state

    state = cauchy.follow(:harlem_shake)
    expect(state).must_be_nil
    expect(cauchy.cursor.value).must_equal :eating
  end

  it "retreats along specific transitions" do
    cauchy = FSA.cauchy
    cauchy.scan
    expect(cauchy.initial.value).must_equal :asleep
    state = cauchy.retreat(:pooped)
    expect(state.value).must_equal :litterbox
    expect(cauchy.cursor).must_equal state

    state = cauchy.retreat(:harlem_shake)
    expect(state).must_be_nil
    expect(cauchy.cursor.value).must_equal :litterbox
  end

  it "can bump prev and next indefinitely" do
    def strategy(i)
      State::STRATEGY.to_a[i % State::STRATEGY.count]
    end

    @fsa.chain_state(:solo, :final)
    expect(@fsa.cursor.value).must_equal :final
    25.times { |i|
      @fsa.prev strategy(i)
      expect(@fsa.cursor.value).must_equal :initial
      @fsa.next strategy(i)
      expect(@fsa.cursor.value).must_equal :final
    }
  end
end
