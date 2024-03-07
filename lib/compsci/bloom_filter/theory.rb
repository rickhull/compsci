# functions corresponding to the theory of optimal sizing and tuning
module CompSci
  class BloomFilter
    FPR = 0.01 # false positive rate; just a default, overrideable

    # calculate once and reuse
    LOG2 = Math.log(2)
    LOG2_SQUARED = LOG2**2

    # Math: some definitions
    # ----
    # 1. FPR: 1 - e^(-1 * k * n/m))^k        # source: ChatGPT
    # 2. num_items: (-1 * m/k) * ln(1 - X/m) # source: Swamidass & Baldi (2007)
    # where:
    #   k = num_hashes
    #   n = num_items
    #   m = num_bits
    #   X = num_on_bits

    # estimate the number of items given the state of the bitmap
    # this is from definition 2 above, Swamidass & Baldi (2007)
    def self.num_items(num_bits, num_hashes, on_count)
      ((-1.0 * num_bits / num_hashes) *
        Math.log(1 - on_count.to_f / num_bits)).ceil
    end

    # FPR definition says the false positive rate is the "percent full"
    # (i.e. the percentage of the bitmap with bits turned on) raised to the
    # number of hashes.  So we now have third definition:
    #
    # 3. percent_full: 1 - e^(-1 * k * n/m))
    #
    # A handy way to think about this is that 1% FPR can be had by 0.5**6

    def self.percent_full(num_bits, num_hashes, num_items)
      1 - Math::E**(-1.0 * num_hashes * num_items / num_bits)
    end

    def self.fpr(num_bits, num_hashes, num_items)
      self.percent_full(num_bits, num_hashes, num_items)**num_hashes
    end

    # Given an expected number of items and a maximum FPR, how many bits
    # and rounds of hashing are required?

    # Based on the FPR definition, we can conclude (don't ask me how):
    #
    # 4. num_bits: (-1 * num_items * ln(fpr) / ln(2)**2).ceil
    #
    # This will yield the smallest number of bits required to maintain the
    # FPR at the specified num_items.  This means our choice of num_bits
    # requires us to use a single corresponding number of hashes.  i.e.
    # The optimal number of bits requires the optimal number of hashes:
    #
    # 5. num_hashes: (ln(2) * num_bits / num_items).ceil

    def self.num_bits(num_items, fpr: FPR)
      (-1 * num_items * Math.log(fpr) / LOG2_SQUARED).ceil
    end

    def self.num_hashes(num_bits, num_items)
      (LOG2 * num_bits / num_items).ceil
    end

    # given num_items and FPR, chain the calls to num_bits and num_hashes and
    # return both values
    def self.optimal(num_items, fpr: FPR)
      num_bits = self.num_bits(num_items, fpr: fpr)
      [num_bits, self.num_hashes(num_bits, num_items)]
    end

    # That said, it is possible to do less hashing at the cost of more bits.
    # I don't know how to analytically determine this but there is a numerical
    # approximation below.

    # how many bits do I need for specified num_items and num_hashes?
    def self.more_bits(num_items, num_hashes, fpr: FPR)
      nb = self.num_bits(num_items, fpr: FPR)
      nh = self.num_hashes(nb, num_items)
      return nb if num_hashes == nh

      # increase num bits until we are under FPR
      step = nb * 0.01
      mult = 0
      mult += 1 while self.fpr(nb + step * mult, num_hashes, num_items) > fpr
      puts "mult = #{mult}"
      nb += step * mult

      # descrease num bits until we are back over FPR
      step *= 0.1
      mult = 0
      mult += 1 while self.fpr(nb - step * mult, num_hashes, num_items) < fpr
      puts "mult = #{mult}"
      (nb - step * (mult - 1)).ceil # the penultimate value
    end

    # determine the optimal tuning values and return a new BloomFilter
    def self.generate(num_items, num_hashes: nil, fpr: FPR)
      if num_hashes
        b = self.more_bits(num_items, num_hashes, fpr: FPR)
        h = num_hashes
      else
        b, h = self.optimal(num_items, fpr: fpr)
      end
      self.new(num_bits: b, num_hashes: h)
    end

    # given num_bits and num_hashes: how many items can we store at what FPRs?
    def self.analyze(num_bits, num_hashes)
      pct_full = 0 # 1 to 99, in practice
      results = []
      fpr_targets = [0.001, 0.01, 0.05, 0.1, 0.25, 0.5]
      while pct_full < 99
        pct_full += 1
        flt_full = pct_full / 100.0
        on_count = flt_full * num_bits
        num_items = self.num_items(num_bits, num_hashes, on_count)
        fpr = flt_full**num_hashes
        break if fpr_targets.empty?
        if fpr >= fpr_targets[0] - 0.0001
          fpr_targets.shift
          results << [pct_full, num_items, fpr]
        end
      end
      results
    end

    # convert the raw numbers from analyze to friendlier strings
    def self.analysis(num_bits, num_hashes)
      self.analyze(num_bits, num_hashes).map { |(pct, items, fpr)|
        format("%i items\t%0.3f%% FPR\t%i%% full", items, fpr * 100, pct)
      }.join($/)
    end

    # return a float and a label
    def self.bytes(num_bits)
      if num_bits < 9_999
        [(num_bits.to_f / 2**3).ceil, 'B']
      elsif num_bits < 9_999_999
        [(num_bits.to_f / 2**13), 'KB']
      elsif num_bits < 9_999_999_999
        [(num_bits.to_f / 2**23), 'MB']
      else
        [(num_bits.to_f / 2**33), 'GB']
      end
    end
  end
end
