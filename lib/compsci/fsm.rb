require 'set'
require 'compsci/graph'

module CompSci
  class DeterministicError < RuntimeError; end

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
      [[@initial, @final].inspect, @graph].join($/)
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
