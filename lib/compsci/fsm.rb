require 'compsci/graph'

module CompSci
  class FiniteStateMachine
    attr_reader :deterministic, :graph, :initial

    def initialize(deterministic: true)
      @deterministic = deterministic
      if @deterministic
        @graph = Graph.new
      else
        @graph = MultiGraph.new
      end
    end

    def transition(from, to, value)
      @initial ||= from
      @graph.edge(from, to, value)
    end

    # state-transition table
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

    # initial, final, graph
    def to_s
      [[@initial, @final].inspect, @graph].join(NEWLINE)
    end

    # store a string
    def encode(str)
      cursor = @initial
      str.each_char.with_index { |chr, i|
        # is there a transition from cursor with value b?
        priors = @graph.edges(from: cursor, value: chr)
        case priors.count
        when 0
          if i < str.length - 1
            # create intermediate transition
            self.transition(cursor, chr)
            cursor = @id
          else
            # transition to @final
            self.transition_final(cursor, chr)
          end
        when 1
          # use existing transition
          cursor = priors.first.to
        else
          self.nondeterministic!(cursor, chr)
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
        edges = @graph.edges(from: cursor, value: chr)
        return false if edges.empty?
        case edges.count
        when 0
          return false
        when 1 # ok
          cursor = edges[0].to
        else
          self.nondeterministic!(cursor, chr)
        end
      }
      cursor == @final
    end
  end

  DAFSA = DAFSAcceptor
end
