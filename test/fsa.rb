require 'minitest/autorun'
require 'compsci/fsa'

include CompSci

describe State do
  before do
    @state = State.new(:foo)
  end

  it "has a value" do
    expect(@state.value).must_equal :foo
  end

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

  it "efficiently walks forward even in the presence of cycles" do
    cauchy = State.cauchy
    walked = cauchy.walk
    expect(walked.keys.count).must_equal 5
    expect([:asleep, :eating, :hiding,
            :litterbox, :playing]).must_include walked.keys.sample.value

    turnstile = State.turnstile
    walked = turnstile.walk
    expect(walked.keys.count).must_equal 2
    expect([:unlocked, :locked]).must_include walked.keys.sample.value
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

  it "efficiently reverse searches for State values" do
    cauchy = State.cauchy
    litterbox = cauchy.rsearch(:litterbox)
    expect(litterbox).must_be_kind_of State
    expect(litterbox.value).must_equal :litterbox

    playing = cauchy.rsearch(:playing)
    expect(playing).must_be_kind_of State
    expect(playing.value).must_equal :playing
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

    @fsa.chain_new_state(:transition, :final)
    expect(@fsa.cursor).wont_equal @fsa.initial
    expect(@fsa.cursor).must_be_kind_of State
    expect(@fsa.cursor.value).must_equal :final

    @fsa.reset_cursor
    expect(@fsa.cursor).must_equal @fsa.initial

    final = @fsa.follow(:transition)
    expect(final).must_be_kind_of State
    expect(final.value).must_equal :final
    expect(@fsa.cursor).must_equal final
  end

  it "allows cycles" do
    expect(@fsa.initial).must_be_kind_of State
    expect(@fsa.initial.value).must_equal :initial
    expect(@fsa.cursor).must_equal @fsa.initial

    @fsa.chain_new_state(:out, :other)
    @fsa.chain_extant_state(:back, :initial)
    expect(@fsa.cursor.value).must_equal :initial

    other = @fsa.follow(:out)
    expect(other.value).must_equal :other
    expect(@fsa.cursor).must_equal other

    @fsa.follow(:back)
    expect(@fsa.cursor.value).must_equal :initial
  end

  it "completes a walk in the presence of cycles" do
    @fsa.chain_new_state(:hop, :middle)
    @fsa.chain_new_state(:skip, :end)
    @fsa.chain_extant_state(:jump, :middle)
    @fsa.chain_extant_state(:slide, :initial)

    expect(@fsa.cursor.value).must_equal :initial

    @fsa.walk!

    expect(@fsa.states.count).must_equal 3
    @fsa.states.each { |state|
      expect([:initial, :middle, :end]).must_include state.value
    }

    expect(@fsa.transitions.count).must_equal 3
  end
end
