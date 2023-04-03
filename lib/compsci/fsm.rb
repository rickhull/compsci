require 'set'
require 'compsci/graph'

module CompSci
  class DeterministicError < RuntimeError; end

  class State
    attr_reader :src, :dest, :value

    def initialize(value)
      @value = value
      @src = {}
      @dest = {}
    end

    # add state to @dest
    def add_dest(transition, state)
      @dest[transition] = state
    end

    # update the dest state with its src transition (from self)
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

    # add state to @src
    def add_src(transition, state)
      @src[transition] = state
    end

    # update the src state with its dest transition (to self)
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
    def walk(states = Set.new, transitions = {})
      deferred = {}
      transitions[self] ||= Set.new
      states.add self

      @dest.each { |t, s|
        if states.include?(s)
          deferred[t] = s
        else
          next if transitions[self].include? t
          transitions[self].add(t)
          s.walk(states, transitions)
        end
        deferred.each { |t, s|
          next if transitions[self].include? t
          transitions[self].add(t)
          s.walk(states, transitions)
        }
      }
      [states, transitions]
    end

    # DFS via @dest transitions
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

    # DFS via @src transitions
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
      fsa.chain_state('Push', :locked)
      fsa.chain_state('Coin', :unlocked)
      fsa.chain_state('Coin', :unlocked)
      fsa.chain_state('Push', :locked)
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

    attr_reader :initial, :cursor, :walk

    def initialize(initial)
      @initial = initial.is_a?(State) ? initial : State.new(initial)
      @cursor = @initial
      self.walk!
    end

    def reset_cursor
      @cursor = @initial
    end

    def follow(transition)
      if (found = @cursor.follow(transition))
        @cursor = found
      end
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

    def chain_state(input, state_value)
      if (state = self.search(state_value))
        @cursor.add_dest!(input, state)
        @cursor = state
      else
        @cursor = @cursor.new_dest(input, state_value)
      end
    end

    def transition(src, input, dest)
      if(state = self.search(src))
        @cursor = state
        self.chain_state(input, dest)
      else
        raise "could not find #{src}"
      end
    end

    def walk!
      @walk = @initial.walk
    end

    def states
      @walk[0]
    end

    def transitions
      @walk[1]
    end

    def to_s
      self.states.map(&:to_s).join($/)
    end
  end
  FSA = FiniteStateAutomaton

  class FiniteStateMachine
    #
    # Pre-made FSMs
    #

    def self.turnstile
      fsm = self.new
      fsm.transition(:locked, :locked, 'Push')
      fsm.transition(:locked, :unlocked, 'Coin')
      fsm.transition(:unlocked, :unlocked, 'Coin')
      fsm.transition(:unlocked, :locked, 'Push')
      fsm
    end

    def self.cauchy
      # https://blog.burntsushi.net/transducers/
      fsm = self.new
      fsm.transition(:asleep, :eating, :food)
      fsm.transition(:eating, :hiding, :loud_noise)
      fsm.transition(:hiding, :eating, :quiet_calm)
      fsm.transition(:eating, :litterbox, :digest_food)
      fsm.transition(:asleep, :playing, :something_moved)
      fsm.transition(:playing, :asleep, :quiet_calm)
      fsm.transition(:litterbox, :asleep, :pooped)
      fsm
    end

    attr_reader :graph, :initial

    def initialize
      @graph = MultiGraph.new
      @initial = nil
    end

    def transition(src, dest, value)
      @initial ||= src
      @graph.edge(src, dest, value)
    end

    def walk(*inputs)
      cursor = @initial
      inputs.each { |input|
        cursor = self.follow(cursor, input)
        return false unless cursor
      }
      cursor
    end

    def follow(src, value)
      @graph.follow(src, value)
    end

    def to_s
      @graph.to_s
    end
  end
  FSM  = FiniteStateMachine

  class DeterministicFiniteStateMachine < FiniteStateMachine
    attr_accessor :check_follow, :check_add

    def initialize
      super()
      @check_add    = true
      @check_follow = false
    end

    def transition(src, dest, value)
      if @check_add and !@graph.edges(src: src, value: value).empty?
        raise(DeterministicError, "multiple edges for #{value} from #{src}")
      end
      @initial ||= src
      @graph.edge(src, dest, value)
    end

    def follow(src, value)
      if @check_follow
        # we can't use Graph#follow because it allows nondeterminism
        transitions = @graph.edges(src: src, value: value)
        case transitions.count
        when 0 then false
        when 1 then transitions.first.dest
        else
          raise(DeterministicError, "multiple edges for #{value} from #{src}")
        end
      else
        @graph.follow(src, value)
      end
    end
  end
  DFSM = DeterministicFiniteStateMachine

  # Deterministic Acyclic Finite State Acceptor
  # Has a single initial state and a single final state
  #
  class DAFSAcceptor
    attr_reader :graph, :id, :initial, :final
    attr_accessor :check_add, :check_follow

    def initialize
      @graph = DAG.new  # directed acyclic graph
      @id = 0           # auto-increment when edges are added
      @initial = @id    # track initial state
      @final = nil      # track final state
      @check_add = true
      @check_follow = false
      @last = nil
    end

    # add a transition, auto-incrementing @id
    def transition(src, value)
      if @check_add and !@graph.edges(src: src, value: value).empty?
        raise(DeterministicError, "multiple edges for #{value} from #{src}")
      end
      @id += 1
      @graph.edge(src, @id, value)
    end

    # add final transition, intializing or reusing @final
    def transition_final(src, value)
      if @final.nil?
        @id += 1
        @final = @id
      end
      @graph.edge(src, @final, value)
    end

    def follow(src, value)
      if @check_follow
        transitions = @graph.edges(src: src, value: value)
        case transitions.count
        when 0 then false
        when 1 then transitions.first.dest
        else
          raise(DeterministicError, "multiple edges for #{value} from #{src}")
        end
      else
        @graph.follow(src, value)
      end
    end

    # initial, final, graph
    def to_s
      [[@initial, @final].inspect, @graph].join(NEWLINE)
    end

    def eval(state)

    end

    # store a string
    def encode(str)
      cursor = @initial
      str.each_char.with_index { |chr, i|
        existing = self.follow(cursor, chr)
        if existing
          cursor = existing
        else
          if i < str.length - 1
            self.transition(cursor, chr)
            cursor = @id
          else
            self.transition_final(cursor, chr)
          end
        end
      }
      @final ||= cursor
      self
    end

    def ingest(str)
      state, suffix = self.suffix(str)
      self.combine_suffixes(state)
      self.add_suffix(state, suffix)
      self.combine_suffixes(@initial)
      self
    end

    # called recursively
    def combine_suffixes(state)
      t = self.last_transition(state)
      if !t
        @final ||= state
        if state != @final
          # patch the edge to point to @final; there should be only 1
          edge = @graph.assert_edge(dest: state)
          @graph.delete(edge)
          @graph.add_edge(edge.with(dest: @final))
        end
        return
      end

      # recursive call!
      self.combine_suffixes(t.dest)

      # now we have t, the transition for the final char of the prior word
      # see if there is an existing equivalent state

      @graph.each_edge(dest: t.dest, value: t.value) { |equiv|
        if equiv.src != t.src
          # create new edge pointing to equiv
          # repoint prior edge to new edge
          break
        end
      }
    end

    def add_suffix(state, suffix)
      str.each_char { |chr|
        self.transition(state, chr)
        state = @id
      }
    end

    def get_transition(state, chr)
      @graph.each_edge(src: state, value: chr) { |e| return e }
      return nil
    end

    def last_transition(state)
      last = nil
      @graph.each_edge(src: state) { |e|
        last = e if last.nil? or e.value > last.value
      }
      last
    end

    # return remaining after any common prefix, and last state of common prefix
    def suffix(str)
      state = @initial
      pos = 0
      str.each_char { |chr|

        existing = self.follow(state, chr)
        break unless existing
        state = existing
        pos += 1
      }
      [str[pos..], state]
    end

    def add_suffix(state, str)
    end

    # is this string recognized?
    def accept?(str)
      raise("no final state") if @final.nil?
      cursor = @initial
      str.each_char { |chr|
        transition = self.follow(cursor, chr)
        return false unless transition
        cursor = transition
      }
      cursor == @final
    end
  end
  DAFSA = DAFSAcceptor
end
