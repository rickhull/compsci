require 'set'

module CompSci
  class NotFound < RuntimeError; end

  class State
    def self.turnstile
      locked = State.new(:locked)
      locked.add_dest!(:push, locked)
      unlocked = locked.new_dest(:coin, :unlocked)
      unlocked.add_dest!(:coin, unlocked)
      unlocked.add_dest!(:push, locked)
      locked
    end

    def self.cauchy
      asleep = State.new(:asleep)
      eating = asleep.new_dest(:food, :eating)
      eating.new_dest(:loud_noise, :hiding).add_dest!(:quiet_calm, eating)
      eating.new_dest(:digest_food, :litterbox).add_dest!(:pooped, asleep)
      asleep.new_dest(:movement, :playing).add_dest!(:quiet_calm, asleep)
      asleep
    end

    attr_reader :src, :dest, :value

    def initialize(value)
      @value = value
      @src = {}
      @dest = {}
    end

    # add State to @dest
    def add_dest(transition, state)
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

    # recursive call; walk the FSA but never rewalk a transition
    def walk(walked = {})
      deferred = {}
      walked[self] ||= Set.new

      @dest.each { |t, s|
        if walked.key?(s)
          deferred[t] = s
        else
          next if walked[self].include? t
          walked[self].add(t)
          s.walk(walked)
        end
        deferred.each { |t, s|
          next if walked[self].include? t
          walked[self].add(t)
          s.walk(walked)
        }
      }
      walked
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
  end

  class FiniteStateAutomaton
    #
    # Pre-made FSAs
    #

    def self.turnstile
      fsa = self.new(:locked)
      fsa.transition(:locked,   'Push', :locked)
      fsa.transition(:locked,   'Coin', :unlocked)
      fsa.transition(:unlocked, 'Coin', :unlocked)
      fsa.transition(:unlocked, 'Push', :locked)
      fsa
    end

    def self.chained
      fsa = self.new(:locked)
      fsa.chain_extant_state('Push', :locked)
      fsa.chain_new_state('Coin', :unlocked)
      fsa.chain_extant_state('Coin', :unlocked)
      fsa.chain_extant_state('Push', :locked)
      fsa
    end

    def self.cauchy
      # https://blog.burntsushi.net/transducers/
      fsa = self.new(:asleep)
      fsa.transition(:asleep,    :food,        :eating)
      fsa.transition(:eating,    :loud_noise,  :hiding)
      fsa.transition(:hiding,    :quiet_calm,  :eating)
      fsa.transition(:eating,    :digest_food, :litterbox)
      fsa.transition(:asleep,    :movement,    :playing)
      fsa.transition(:playing,   :quiet_calm,  :asleep)
      fsa.transition(:litterbox, :pooped,      :asleep)
      fsa
    end

    attr_reader :initial, :cursor, :transitions

    def initialize(initial)
      @initial = initial.is_a?(State) ? initial : State.new(initial)
      @cursor = @initial
      self.walk!
    end

    def cursor=(val)
      # make sure it's reachable
      value = val.is_a?(State)? val.value : val
      state = @initial.search(value)
      state ? (@cursor = state) : raise(NotFound, value.inspect)
    end

    def follow(transition)
      found = @cursor.follow(transition)
      found ? (@cursor = found) : found
    end

    def search(value)
      return @cursor if @cursor.value == value
      return @initial if @initial.value == value
      if (res = @cursor.search(value))
        res
      elsif (res = @initial.search(value))
        res
      else
        false
      end
    end

    def rsearch(value)
      return @cursor if @cursor.value == value
      @cursor.rsearch(value)
    end

    def chain_new_state(input, value)
      @cursor = @cursor.new_dest(input, value)
    end

    def chain_extant_state(input, value)
      raise(NotFound, value.inspect) unless state = self.search(value)
      @cursor.add_dest!(input, state)
      @cursor = state
    end

    def chain_state(input, value)
      begin
        self.chain_extant_state(input, value)
      rescue NotFound
        self.chain_new_state(input, value)
      end
    end

    # create new transition from src to dest
    # src, input, and dest are all values.  src and dest are *not* States
    def transition(src, input, dest)
      raise(NotFound, src.inspect) unless state = self.search(src)
      @cursor = state
      self.chain_state(input, dest)
    end

    def walk!
      @transitions = @initial.walk
    end

    def states
      @transitions.keys
    end

    def to_s
      self.states.map(&:to_s).join($/)
    end
  end
  FSA = FiniteStateAutomaton
end
