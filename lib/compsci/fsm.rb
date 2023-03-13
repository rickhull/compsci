require 'compsci/dag'

module CompSci
  class FiniteStateMachine
    def self.turnstile
      fsm = self.new

      locked = fsm.add_state 'Locked', initial: true
      unlocked = fsm.add_state 'Unlocked'

      fsm.add_transition(locked, locked, 'Push')
      fsm.add_transition(locked, unlocked, 'Coin')
      fsm.add_transition(unlocked, unlocked, 'Coin')
      fsm.add_transition(unlocked, locked, 'Push')
      fsm
    end

    attr_reader :deterministic, :graph, :initial

    def initialize(deterministic: true)
      @deterministic = deterministic
      if @deterministic
        @graph = Graph.new
      else
        @graph = MultiGraph.new
      end
    end

    def add_state(value, initial: false)
      s = @graph.v(value)
      @initial = s if initial
      s
    end

    def add_transition(from, to, value)
      @graph.e(from, to, value)
    end

    # state-transition table
    def to_s
      state_width = 0
      @graph.vtxs.each { |v|
        str = v.value.to_s
        state_width = str.length if str.length > state_width
      }

      input_width = 0
      @graph.edges.each { |e|
        str = e.value.to_s
        input_width = str.length if str.length > input_width
      }

      rows = []
      # header first
      rows << "STATE\t" + @graph.vtxs.map { |v|
        v.value.to_s.ljust(state_width, ' ')
      }.join("\t")
      rows << "INPUT\t" + @graph.vtxs.map { '-' * state_width }.join("\t")
      rows += @graph.edges.map { |edge|
        input = edge.value.to_s.ljust(input_width, ' ')
        ary = [input]
        ary += @graph.vtxs.map { |vtx|
          cell = edge.from == vtx ? edge.to.value.to_s : ''
          cell.ljust(state_width, ' ')
        }
        ary.join("\t")
      }
      rows.join("\n")
    end
  end

  FSM = FiniteStateMachine

  # Deterministic Acyclic Finite State Acceptor
  #
  class DAFSAcceptor
    class DeterministicError < RuntimeError; end

    attr_reader :dag, :first, :id
    attr_accessor :final

    def initialize
      @dag = DAG.new
      @id = 0
      @first = self.new_state
    end

    def states
      @dag.vtxs
    end

    def new_state
      state, @id = @dag.v(@id), @id + 1
      state
    end

    def add_state(from_state, input)
      to_state = self.new_state
      @dag.e from_state, to_state, input
      to_state
    end

    def add_final(from_state, input)
      @final = self.add_state(from_state, input)
    end

    def to_s
      [[@first, @final].map(&:value).inspect, @dag].join(NEWLINE)
    end

    def accept?(input)
      cursor = @first
      input.each_char { |chr|
        hsh = @dag.edge[cursor]
        return false if hsh.nil?
        edges = hsh.values.select { |e| e.value == chr }
        case edges.count
        when 0
          return false
        when 1 # ok
          cursor = edges[0].to
        else
          raise(DeterministicError, "multiple edges for #{chr} from #{cursor}")
        end
      }
      cursor == @final
    end
  end

  DAFSA = DAFSAcceptor
end
