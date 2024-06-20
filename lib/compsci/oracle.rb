# based on https://people.ischool.berkeley.edu/~nick/aaronson-oracle/index.html
# via https://github.com/elsehow/aaronson-oracle

module CompSci
  module Oracle
    # A ring buffers stores only the last N items, characters in this case
    # After updating with AAAAA, the value is ['A', 'A', 'A', 'A', 'A']
    # Now update with B B: ['B', 'B', 'A', 'A', 'A']
    # We use a cursor and modulo to pick where to insert.
    # The last 5 chars are not BBAAA but AAABB.
    class Ring
      attr_reader :limit, :cursor, :storage

      def initialize(limit = 5)
        @limit = limit
        @cursor = 0
        @storage = Array.new(@limit, '')
      end

      def update(val)
        @storage[@cursor % @limit] = val
        @cursor += 1
        self
      end

      def to_s
        cursor = @cursor % @limit
        # steep:ignore:start
        (@storage[cursor, @limit - cursor] + @storage[0, cursor]).join
        # steep:ignore:end
      end

      def full?
        @cursor >= @limit
      end
    end

    # A Model has a ring (input buffer),
    #   adds a hash to track next-letter frequences,
    #   and tracks its record of predictions
    class Model
      def self.summarize(hsh)
        best_key = nil
        best_val = 0
        best_pct = 0.0

        total = hsh.values.sum
        pct = {}

        hsh.each { |k, v|
          if v > best_val
            pct[k] = (v / total.to_f).round(4)
            best_key = k
            best_val = v
            best_pct = pct[k]
          end
        }

        { top: pct.sort_by { |k, v| -1 * v }.take(3).to_h,
          best_key: best_key,
          best_val: best_val,
          best_pct: best_pct, }
      end

      attr_reader :ring, :freq, :pred

      def initialize(limit = 5)
        @ring = Ring.new(limit)
        @freq = Hash.new
        @pred = Hash.new(0)
      end

      def to_s
        format("%s\t%.1f%%", @ring, self.percentage)
      end

      # Rational 0..1, correct / total
      def ratio
        return 1r if @pred.empty?
        Rational(@pred[:correct], @pred[:correct] + @pred[:incorrect])
      end

      # Float 0.0..100.0 based on ratio
      def percentage
        (self.ratio * 100.0).round(1).to_f # convince steep it's a Float
      end

      def prediction
        h = @freq[@ring.to_s] and Model.summarize(h)
      end

      def update(val)
        # only make predictions once the ring is full
        if @ring.full?
          buf = @ring.to_s

          # update @pred if we've seen this sequence before
          if (h = @freq[buf])
            pred = Model.summarize(h)
            @pred[(val == pred[:best_key]) ? :correct : :incorrect] += 1
          end

          # update @freq
          @freq[buf] ||= Hash.new(0)
          @freq[buf][val] += 1
        end

        # update @ring
        @ring.update(val)
        self
      end

      def accept(str)
        raise("unexpected: #{str.inspect}") if !str.is_a?(String) or str.empty?
        str.each_char { |c| self.update(c) }
        self
      end
    end
  end
end
