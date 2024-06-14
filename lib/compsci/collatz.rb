module CompSci
  module Collatz
    def self.once(n)
      (n % 2 == 0) ? (n/2) : (3*n + 1)
    end

    def self.loop(n, register: self.register)
      raise "invalid: #{n.inspect}" if !n.is_a?(Integer) or n <= 0
      while n != 1
        register[n] += 1
        n = self.once(n)
      end
      register[1] += 1 # helps track number of iterations in the register
      register
    end

    def self.register
      Hash.new(0)
    end

    def self.summarize(reg)
      best_key = nil
      best_val = 0

      total = reg[1]
      pct = {}

      reg.each { |k, v|
        # skip 1 as it will always dominate
        next if k == 1
        if v >= best_val
          pct[k] = (v / total.to_f).round(4)
          best_key = k
          best_val = v
        end
      }

      { top: pct.sort_by { |k, v| -1 * v }.take(5).to_h,
        best_key: best_key,
        best_val: best_val }
    end
  end
end
