require 'compsci'

module CompSci
  class Elo
    # rating_a and rating_b are positive numbers
    def self.expected(rating_a, rating_b)
      DEFAULT.expected(rating_a, rating_b)
    end

    # outcome_a is number between 0 and 1
    # 1 indicates a "win" for A, 0 indicates a "win" for B
    # 0.5 indicates a draw
    # 0.6 might indicate a "win" for A, like best 3 sets out of 5.
    def self.update(rating_a, rating_b, outcome_a)
      DEFAULT.update(rating_a, rating_b, outcome_a)
    end

    attr_reader :initial, :k, :c

    def initialize(initial: 1000, k: 32, c: 480)
      @initial = initial
      @k = k
      @c = c.to_f
    end

    CLASSIC = { initial: 1500, k: 32, c: 400 }
    MODERN = { initial: 1000, k: 32, c: 480 }
    DEFAULT = self.new(**MODERN)

    def expected(rating_a, rating_b)
      CompSci.positive!(rating_a) and CompSci.positive!(rating_b)
      1 / (1 + 10**((rating_b - rating_a) / @c))
    end

    def update(rating_a, rating_b, outcome)
      raise(ArgumentError, outcome.inspect) unless (0..1).include? outcome
      exp_a = expected(rating_a, rating_b)
      exp_b = expected(rating_b, rating_a)

      [rating_a + @k * (outcome - exp_a),
       rating_b + @k * (1 - outcome - exp_b)].map(&:round)
    end

    class Player
      include Comparable

      def self.init_pool(count, elo)
        Array.new(count) { Player.new(elo) }
      end

      attr_accessor :rating, :elo

      def initialize(elo)
        raise(ArgumentError, elo.inspect) unless elo.is_a? Elo
        @elo = elo
        @rating = @elo.initial
      end

      def <=>(opponent)
        @rating <=> opponent.rating
      end

      def update(opponent, outcome)
        @rating, opponent.rating = @elo.update(@rating,
                                               opponent.rating,
                                               outcome)
      end
    end
  end
end
