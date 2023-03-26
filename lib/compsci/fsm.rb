require 'compsci/graph'

module CompSci
  class DeterministicError < RuntimeError; end

  class FiniteStateMachine
    #
    # Pre-made FSMs
    #

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

    def self.turnstile
      fsm = self.new
      fsm.transition(:locked, :locked, 'Push')
      fsm.transition(:locked, :unlocked, 'Coin')
      fsm.transition(:unlocked, :unlocked, 'Coin')
      fsm.transition(:unlocked, :locked, 'Push')
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
    def self.nondeterministic!(src, val)
      raise(DeterministicError, "multiple edges for #{val} from #{src}")
    end

    def transition(src, dest, value)
      if !@graph.edges(src: src, value: value).empty?
        self.class.nondeterministic!(src, value)
      end
      @initial ||= src
      @graph.edge(src, dest, value)
    end

    # we can't use Graph#follow because it allows nondeterminism
    def follow(src, value)
      transitions = @graph.edges(src: src, value: value)
      case transitions.count
      when 0 then false
      when 1 then transitions.first.dest
      else
        self.class.nondeterministic!(src, value)
      end
    end
  end
  DFSM = DeterministicFiniteStateMachine

  # Deterministic Acyclic Finite State Acceptor
  # Has a single initial state and a single final state
  #
  class DAFSAcceptor
    def self.nondeterministic!(src, chr)
      raise(DeterministicError, "multiple edges for #{chr} from #{src}")
    end

    attr_reader :graph, :id, :initial, :final

    def initialize
      @graph = DAG.new  # directed acyclic graph
      @id = 0           # auto-increment when edges are added
      @initial = @id    # track initial state
      @final = nil      # track final state
    end

    # add a transition, auto-incrementing @id
    def transition(src, value)
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
      transitions = @graph.edges(src: src, value: value)
      case transitions.count
      when 0 then false
      when 1 then transitions.first.dest
      else
        self.class.nondeterministic!(src, value)
      end
    end

    # initial, final, graph
    def to_s
      [[@initial, @final].inspect, @graph].join(NEWLINE)
    end

    # store a string
    def encode(str)
      cursor = @initial
      str.each_char.with_index { |chr, i|
        existing = self.follow(cursor, chr)
        if existing
          cursor = existing
        else
          if i < str.length - 1  # intermediate transition
            self.transition(cursor, chr)
            cursor = @id
          else # transition to @final
            self.transition_final(cursor, chr)
          end
        end
      }
      @final ||= cursor
      self
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
