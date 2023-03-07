require 'compsci/dag'

module CompSci
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
