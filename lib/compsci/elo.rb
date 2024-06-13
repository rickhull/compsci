module CompSci
  class Elo
    attr_reader :initial, :k, :c

    def initialize(initial: 1000, k: 32, c: 480.0)
      @initial = initial  # initial rating, typically 1500
      @k = k              # maximum adjustment per update, typically 32
      @c = c.to_f         # a constant, typically 400
    end

    # rating_a and rating_b are positive numbers
    def expected(rating_a, rating_b)
      1 / (1 + 10.0**((rating_b - rating_a) / @c))
    end

    # outcome_a is number between 0 and 1
    # 1 indicates a "win" for A, 0 indicates a "win" for B
    # 0.5 indicates a draw
    # 0.6 might indicate a "win" for A, like best 3 sets out of 5.
    def update(rating_a, rating_b, outcome)
      raise(ArgumentError, outcome.inspect) unless (0..1).include? outcome
      ea, eb = expected(rating_a, rating_b), expected(rating_b, rating_a)

      [rating_a + @k * (outcome - ea),
       rating_b + @k * (1 - outcome - eb)].map(&:round)
    end
  end

  # That's all we need, above.  Here, have some convenience methods:

  class Elo
    # Elo's choice of 1500 was somewhat arbitrary, perhaps intended to keep
    # all worthy ratings at 4 digits, effectively ignoring ratings below 1000
    # See
    # https://en.wikipedia.org/wiki/Elo_rating_system#Suggested_modification
    # for why C=480 might be preferable to C=400
    CHESS = self.new(initial: 1500, k: 32, c: 400.0)
    DEFAULT = self.new

    def Elo.expected(rating_a, rating_b)
      DEFAULT.expected(rating_a, rating_b)
    end

    def Elo.update(rating_a, rating_b, outcome_a)
      DEFAULT.update(rating_a, rating_b, outcome_a)
    end
  end

  # Let's add a Player class to track Elo config, player rating, record, etc.

  class Elo
    class Player
      include Comparable

      def self.init_pool(count, elo: nil)
        Array.new(count) { Player.new(elo: elo) }
      end

      def self.avg_rating(pool)
        (pool.map(&:rating).sum.to_f / pool.count).round
      end

      def self.roll(type: :default)
        case type
        when :default      # win=1   lose=0   draw=0.5
          d200 = rand(200)
          case d200
          when 0,1         # draw, 1%
            0.5
          else             # even wins 49.5%, odd loses 49.5%
            d200 % 2 == 0 ? 1.0 : 0.0
          end
        when :rand         # any float 0..1
          rand
        when :no_draw      # win=1   lose=1
          rand(2) == 0 ? 1.0 : 0.0
        else
          raise(ArgumentError, type.inspect)
        end
      end

      def self.skill_roll(skill_a = 0.5, skill_b = 0.5, type: :default)
        skill = (skill_a + (1 - skill_b)) / 2.0
        r = rand
        case type
        when :default      # win=1   lose=0   draw=0.5
          if r <= 0.01 # 1% chance of a draw
            0.5
          else
            r <= (0.01 + skill * 0.99) ? 1.0 : 0.0
          end
        when :rand
          (r + skill - 0.5).clamp(0.0, 1.0)
        when :no_draw
          r <= skill ? 1.0 : 0.0
        else
          raise(ArgumentError, type.inspect)
        end
      end

      attr_accessor :rating, :elo, :skill, :wins, :losses, :draws

      def initialize(elo: nil, skill: 0.5)
        elo = Elo.new if elo.nil?
        raise(ArgumentError, elo.inspect) unless elo.is_a? Elo
        @elo = elo
        @rating = @elo.initial
        @skill = skill
        @wins = 0
        @losses = 0
        @draws = 0
      end

      def <=>(opponent)
        @rating <=> opponent.rating
      end

      def update(opp, outcome)
        if outcome < 0.5
          @losses += 1
          opp.wins += 1
        elsif outcome > 0.5
          @wins += 1
          opp.losses += 1
        else
          @draws += 1
          opp.draws += 1
        end
        @rating, opp.rating = @elo.update(@rating, opp.rating, outcome)
      end

      def simulate(opp, type: :default)
        outcome = Player.skill_roll(@skill, opp.skill, type: type)
        update(opp, outcome)
        outcome
      end

      def record
        win_pct = 100.0 * (@wins + 0.5 * @draws) / (@wins + @losses + @draws)
        win_pct = 0 if win_pct.nan?
        format("%i-%i-%i  %.1f %%", @wins, @losses, @draws, win_pct)
      end

      def to_s
        format("(%.3f) %s: %s", @skill, @rating.to_s.rjust(4, ' '), record())
      end
    end
  end
end
