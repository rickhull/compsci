require 'compsci/graph'

module CompSci
  class FiniteStateMachine # deterministic
    class DeterministicError < RuntimeError; end

    def self.nondeterministic!(from, chr)
      raise(DeterministicError, "multiple edges for #{chr} from #{from}")
    end

    attr_reader :graph, :initial

    def initialize
      @graph = Graph.new
    end

    def transition(from, to, value)
      @initial ||= from
      @graph.edge(from, to, value)
    end

    def follow(from, value)
      transitions = @graph.edges(from: from, value: value)
      case transitions.count
      when 0
        false
      when 1
        transitions.first.to
      else
        self.class.deterministic!(from, value)
      end
    end

    def walk(*inputs)
      cursor = @initial
      inputs.each { |input|
        cursor = self.follow(cursor, input)
        return false unless cursor
      }
      cursor
    end

    # state-transition table; @graph.to_s is usually nicer
    def to_s
      state_width = 0
      @graph.vtxs.each { |v|
        str = v.to_s
        state_width = str.length if str.length > state_width
      }

      input_width = 0
      @graph.each_edge { |e|
        str = e.value.to_s
        input_width = str.length if str.length > input_width
      }

      rows = []
      # header first
      rows << "STATE".ljust(input_width, ' ') + "\t" + @graph.vtxs.map { |v|
        v.to_s.ljust(state_width, ' ')
      }.join("\t")
      rows << "INPUT".ljust(input_width, ' ') + "\t" + @graph.vtxs.map {
        '-' * state_width
      }.join("\t")
      rows += @graph.edges.map { |edge|
        input = edge.value.to_s.ljust(input_width, ' ')
        ary = [input]
        ary += @graph.vtxs.map { |vtx|
          (edge.from == vtx ? edge.to.to_s : '').ljust(state_width, ' ')
        }
        ary.join("\t")
      }
      rows.join("\n")
    end

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
  end

  FSM = FiniteStateMachine

  class NonDeterministicFiniteStateMachine < FiniteStateMachine
    def initialize
      @graph = MultiGraph.new
    end

    def follow(from, value)
      transitions = @graph.edges(from: from, value: value)
      case transitions.count
      when 0
        false
      when 1
        transitions.first.to
      else
        transitions.sample.to
      end
    end
  end

  NDFSM = NonDeterministicFiniteStateMachine

  # Deterministic Acyclic Finite State Acceptor
  # Has a single initial state and a single final state
  #
  class DAFSAcceptor
    class DeterministicError < RuntimeError; end

    def self.nondeterministic!(from, chr)
      raise(DeterministicError, "multiple edges for #{chr} from #{from}")
    end

    attr_reader :graph, :id, :initial, :final

    def initialize
      @graph = DAG.new  # directed acyclic graph
      @id = 0           # auto-increment when edges are added
      @initial = @id    # track initial state
      @final = nil      # track final state
    end

    # add a transition, auto-incrementing @id
    def transition(from, value)
      @id += 1
      @graph.edge(from, @id, value)
    end

    # add final transition, intializing or reusing @final
    def transition_final(from, value)
      if @final.nil?
        @id += 1
        @final = @id
      end
      @graph.edge(from, @final, value)
    end

    def follow(from, value)
      transitions = @graph.edges(from: from, value: value)
      case transitions.count
      when 0
        false
      when 1
        transitions.first.to
      else
        self.class.deterministic!(from, value)
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
