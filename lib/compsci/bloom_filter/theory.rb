# class methods (functions) and an instance method
# corresponding to the theory of optimal sizing and tuning of Bloom filters
module CompSci
  # calculate once and reuse
  LOG2 = Math.log(2)
  LOG2_SQUARED = LOG2**2

  class BloomFilter
    FPR = 0.01 # false positive rate; just a default, overrideable

    # Math: some definitions
    # ----
    # 1. FPR: 1 - e^(-1 * k * n/m))^k        # source: ChatGPT
    # 2. items: (-1 * m/k) * ln(1 - X/m) # source: Swamidass & Baldi (2007)
    # where:
    #   k = hashes
    #   n = items
    #   m = bits
    #   X = on_bits

    # estimate the number of items given the state of the bitmap
    # this is from definition 2 above, Swamidass & Baldi (2007)
    def self.items(bits:, hashes:, on_count:)
      ((-1.0 * bits / hashes) * Math.log(1 - on_count.to_f / bits)).ceil
    end

    # note, instance method!
    def estimated_items
      BloomFilter.items(bits: @bits,
                        hashes: @aspects,
                        on_count: @bitmap.on_bits.count)
    end

    # FPR definition says the false positive rate is the "percent full"
    # (i.e. the percentage of the bitmap with bits turned on) raised to the
    # number of hashes.  So we now have third definition:
    #
    # 3. percent_full: 1 - e^(-1 * k * n/m))
    #
    # A handy way to think about this is that 1% FPR can be had by 0.5**6

    def self.percent_full(bits:, hashes:, items:)
      1 - Math::E**(-1.0 * hashes * items / bits)
    end

    def self.fpr(bits:, hashes:, items:)
      self.percent_full(bits: bits, hashes: hashes, items: items)**hashes
    end

    # Given an expected number of items and a maximum FPR, how many bits
    # and rounds of hashing are required?

    # Based on the FPR definition, we can conclude (don't ask me how):
    #
    # 4. bits: (-1 * items * ln(fpr) / ln(2)**2).ceil
    #
    # This will yield the smallest number of bits required to maintain the
    # FPR at the specified items.  This means our choice of bits
    # requires us to use a single corresponding number of hashes.  i.e.
    # The optimal number of bits requires the optimal number of hashes:
    #
    # 5. hashes: (ln(2) * bits / items).ceil

    def self.bits(items:, fpr: FPR)
      (-1 * items * Math.log(fpr) / LOG2_SQUARED).ceil
    end

    def self.hashes(bits:, items:)
      (LOG2 * bits / items).ceil
    end

    # given items and FPR, chain the calls to bits and hashes and
    # return both values
    def self.optimal(items:, fpr: FPR)
      bits = self.bits(items: items, fpr: fpr)
      [bits, self.hashes(bits: bits, items: items)]
    end

    # That said, it is possible to do less hashing at the cost of more bits.
    # I don't know how to analytically determine this but there is a numerical
    # approximation below.

    # how many bits do I need for specified items and hashes?
    def self.more_bits(items:, hashes:, fpr: FPR)
      nb = self.bits(items: items, fpr: FPR)
      nh = self.hashes(bits: nb, items: items)
      return nb if hashes == nh

      # increase num bits until we are under FPR
      step = nb * 0.01
      mult = 0
      mult += 1 while self.fpr(bits: nb + step * mult,
                               hashes: hashes,
                               items: items) > fpr
      puts "mult = #{mult}"
      nb += step * mult

      # descrease num bits until we are back over FPR
      step *= 0.1
      mult = 0
      mult += 1 while self.fpr(bits: nb - step * mult,
                               hashes: hashes,
                               items: items) < fpr
      puts "mult = #{mult}"
      (nb - step * (mult - 1)).ceil # the penultimate value
    end

    # determine the optimal tuning values and return a new BloomFilter
    def self.generate(items:, hashes: nil, fpr: FPR)
      if hashes
        b = self.more_bits(items: items, hashes: hashes, fpr: FPR)
        h = hashes
      else
        b, h = self.optimal(items: items, fpr: fpr)
      end
      self.new(bits: b, hashes: h)
    end

    # given bits and hashes: how many items can we store at what FPRs?
    def self.analyze(bits:, hashes:)
      pct_full = 0 # 1 to 99, in practice
      results = []
      fpr_targets = [0.001, 0.005, 0.01, 0.05, 0.1, 0.25, 0.5]
      # try every percentage from 1% to 99% to determine FPR thresholds
      while pct_full < 99
        pct_full += 1
        flt_full = pct_full / 100.0
        items = self.items(bits: bits,
                           hashes: hashes,
                           on_count: flt_full * bits)
        fpr = flt_full**hashes
        break if fpr_targets.empty?
        if fpr >= fpr_targets[0] - 0.0001
          fpr_targets.shift
          results << [flt_full, items, fpr]
        end
      end
      results
    end

    # convert the raw numbers from analyze to friendlier strings
    def self.analysis(bits:, hashes:)
      self.analyze(bits: bits, hashes: hashes).map { |(pct, items, fpr)|
        format("%i items\t%0.3f%% FPR\t%i%% full", items, fpr * 100, pct * 100)
      }.join($/)
    end
  end
end
