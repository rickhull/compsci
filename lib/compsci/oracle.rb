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
      attr_reader :count, :cursor, :storage

      def initialize(count = 5)
        @count = count
        @cursor = 0
        @storage = Array.new
      end

      def update(val)
        @storage[@cursor % @count] = val
        @cursor += 1
        self
      end

      def to_s
        if @cursor < @count
          @storage
        else
          cursor = @cursor % @count
          @storage[cursor, @count - cursor] + @storage[0, cursor]
        end.join
      end

      def full?
        if @storage.count < @count
          false
        elsif @storage.count == @count
          true
        else
          raise("@storage.count too large: #{@storage.inspect}")
        end
      end
    end

    # A Model has a ring (input buffer),
    #   adds a hash to track next-letter frequences,
    #   and tracks its record of predictions
    class Model
      def self.summarize(hsh)
        best_key = nil
        best_val = 0
        best_pct = 0

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

      def initialize(count = 5)
        @ring = Ring.new(count)
        @freq = Hash.new
        @pred = Hash.new(0)
      end

      def to_s
        format("%s\t%s", @ring, self.prediction)
      end

      # [0..1]
      def correct_pct
        return 1 if @pred.empty?
        @pred[:correct] / (@pred[:correct] + @pred[:incorrect]).to_f
      end

      def update(val)
        if @ring.full?
          key = @ring.to_s
          @freq[key] ||= Hash.new(0)
          @freq[key][val] += 1
        end
        pred = self.prediction
        if pred
          if val == pred[:best_key]
            @pred[:correct] += 1
          else
            @pred[:incorrect] += 1
          end
        end
        @ring.update(val)
        self
      end

      def accept(str)
        raise("unexpected: #{str.inspect}") if !str.is_a?(String) or str.empty?
        str.each_char { |c| self.update(c) }
        self
      end

      def prediction
        if @ring.full?
          h = @freq[@ring.to_s]
          Model.summarize(h) if h and !h.empty?
        end
      end
    end
  end
end
