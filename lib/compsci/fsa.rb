require 'set'

module CompSci
  class NotFound < RuntimeError; end
  class TransitionError < RuntimeError; end

  class State
    def self.comparable!(value)
      value.kind_of?(Comparable) and value or
        raise(TransitionError, "#{value.inspect} isn't Comparable")
    end

    STRATEGY = Set[:first, :last, :min, :max, :sample]

    attr_reader :src, :dest, :value

    def initialize(value)
      @value = value
      @src = {}
      @dest = {}
    end

    # add State to @dest
    def add_dest(transition, state)
      self.class.comparable! transition
      @dest[transition] = state
    end

    # update the dest State with its src transition (from self)
    def add_dest!(transition, state)
      self.add_dest(transition, state).add_src(transition, self)
      state
    end

    # create new State, add it, and update its src transition
    def new_dest(transition, state_value)
      state = self.class.new(state_value)
      self.add_dest!(transition, state)
      state
    end

    # add State to @src
    def add_src(transition, state)
      self.class.comparable! transition
      @src[transition] = state
    end

    # update the src State with its dest transition (to self)
    def add_src!(transition, state)
      self.add_src(transition, state).add_dest(transition, self)
      state
    end

    # create new State, add it, and update its dest transition
    def new_src(transition, state_value)
      state = self.class.new(state_value)
      self.add_src!(transition, state)
      state
    end

    # recursive call; scan the FSA but never rescan a transition
    def scan(scanned = {})
      deferred = {}
      scanned[self] ||= Set.new

      @dest.each { |t, s|
        if scanned.key?(s)
          deferred[t] = s
        else
          next if scanned[self].include? t
          scanned[self].add(t)
          s.scan(scanned)
        end
        deferred.each { |t, s|
          next if scanned[self].include? t
          scanned[self].add(t)
          s.scan(scanned)
        }
      }
      scanned
    end

    # depth first search for a value, via @dest transitions
    def search(value, visited = Set.new)
      return self if @value == value
      return false if visited.include? @value
      visited.add @value

      @dest.each { |t, s|
        next if visited.include? s.value
        if (res = s.search(value, visited))
          return res
        end
      }
      false
    end

    # depth first search for a value, via @src transitions
    def rsearch(value, visited = Set.new)
      return self if @value == value
      return false if visited.include? @value
      visited.add @value

      @src.each { |t, s|
        next if visited.include? s.value
        if (res = s.rsearch(value, visited))
          return res
        end
      }
      false
    end

    def follow(transition)
      @dest[transition]
    end

    def retreat(transition)
      @src[transition]
    end

    def next(strategy)
      raise "unknown: #{strategy.inspect}" unless STRATEGY.include? strategy
      @dest.values.send(strategy)
    end

    def prev(strategy)
      raise "unknown: #{strategy.inspect}" unless STRATEGY.include? strategy
      @src.values.send(strategy)
    end

    def to_s
      lines = [format("[%s]", @value)]
      @dest.each { |t, s|
        lines << format("%s --%s--> %s", @value, t, s.value)
      }
      lines.join($/)
    end

    def inspect
      { value: @value,
        src: @src.keys,
        dest: @dest.keys, }.to_s
    end

    #
    # Pre-made patterns
    #

    def self.turnstile
      locked = State.new(:locked)
      locked.add_dest!(:push, locked)
      unlocked = locked.new_dest(:coin, :unlocked)
      unlocked.add_dest!(:coin, unlocked)
      unlocked.add_dest!(:push, locked)
      locked
    end

    # https://blog.burntsushi.net/transducers/
    def self.cauchy
      asleep = State.new(:asleep)
      eating = asleep.new_dest(:food, :eating)
      eating.new_dest(:loud_noise, :hiding).add_dest!(:quiet_calm, eating)
      eating.new_dest(:digest_food, :litterbox).add_dest!(:pooped, asleep)
      asleep.new_dest(:movement, :playing).add_dest!(:quiet_calm, asleep)
      asleep
    end
  end

  class FiniteStateAutomaton
    attr_reader :initial, :cursor, :states, :transitions

    def initialize(initial)
      @initial = initial.is_a?(State) ? initial : State.new(initial)
      @states = {}
      @states[@initial.value] = @initial
      @cursor = @initial
      self.scan
    end

    def reset_cursor
      @cursor = @initial
    end

    # set the cursor to a known state; may raise NotFound
    def cursor=(val)
      value = val.is_a?(State)? val.value : val
      raise(NotFound, value.inspect) unless @states.key? value
      @cursor = @states[value]
    end

    # move cursor to follow the dest transition
    def follow(transition)
      found = @cursor.follow(transition)
      found ? (@cursor = found) : found
    end

    # move cursor to follow the src transition
    def retreat(transition)
      found = @cursor.retreat(transition)
      found ? (@cursor = found) : found
    end

    # bump cursor forward according to strategy
    def next(strategy = :sample)
      return unless state = @cursor.next(strategy)
      @cursor = state
    end

    # bump cursor backward according to strategy
    def prev(strategy = :sample)
      return unless state = @cursor.prev(strategy)
      @cursor = state
    end

    # search via dest transitions, first from @cursor, then from @initial
    def search(value)
      return @cursor if @cursor.value == value
      return @initial if @initial.value == value
      if res = @cursor.search(value)
        res
      elsif res = @initial.search(value)
        res
      else
        false
      end
    end

    # reverse search via src transitions, only from @cursor
    def rsearch(value)
      return @cursor if @cursor.value == value
      @cursor.rsearch(value)
    end

    # preemptively search for a state matching value; if not found, create it
    def chain_state(input, value)
      known = @states[value]
      if known
        @cursor = @cursor.add_dest!(input, known)
      else
        @cursor = @cursor.new_dest(input, value)
        @states[value] = @cursor
      end
      self
    end

    # create new transition from src to dest
    # src, input, and dest are all values.  src and dest are *not* States
    def transition(src, input, dest)
      raise(NotFound, src.inspect) unless state = @states[src]
      @cursor = state
      self.chain_state(input, dest)
    end

    # register all reachable states and transitions starting from cursor
    def scan(cursor = @initial)
      @cursor = cursor
      @transitions = @cursor.scan
      self
    end

    def to_s
      self.states.values.join($/)
    end

    #
    # Pre-made patterns
    #

    def self.turnstile
      fsa = self.new(:locked)
      fsa.transition(:locked,   'Push', :locked)
      fsa.transition(:locked,   'Coin', :unlocked)
      fsa.transition(:unlocked, 'Coin', :unlocked)
      fsa.transition(:unlocked, 'Push', :locked)
      fsa.scan
    end

    def self.chained
      fsa = self.new(:locked)
      fsa.chain_state('Push', :locked)
      fsa.chain_state('Coin', :unlocked)
      fsa.chain_state('Coin', :unlocked)
      fsa.chain_state('Push', :locked)
      fsa.scan
    end

    def self.cauchy
      fsa = self.new(:asleep)
      fsa.transition(:asleep,    :food,        :eating)
      fsa.transition(:eating,    :loud_noise,  :hiding)
      fsa.transition(:hiding,    :quiet_calm,  :eating)
      fsa.transition(:eating,    :digest_food, :litterbox)
      fsa.transition(:asleep,    :movement,    :playing)
      fsa.transition(:playing,   :quiet_calm,  :asleep)
      fsa.transition(:litterbox, :pooped,      :asleep)
      fsa.scan
    end
  end
  FSA = FiniteStateAutomaton
end
