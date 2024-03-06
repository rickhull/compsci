# stdlib
require 'zlib'
require 'digest'
require 'openssl'

# gems
require 'bitset'

module CompSci
  class BloomFilter
    # from 'digest'
    DIGESTS = %w[MD5 SHA1 SHA256 SHA384 SHA512 RMD160].map { |name|
      Digest(name).new
    }

    # from 'openssl'
    OPENSSL_DIGESTS = %w[SHA1
                         SHA224 SHA256 SHA384 SHA512
                         SHA512-224 SHA512-256
                         SHA3-224 SHA3-256 SHA3-384 SHA3-512
                         BLAKE2s256 BLAKE2b512].map { |name|
      OpenSSL::Digest.new(name)
    }

    # the next two methods return an array of bit indices ("on bits")
    # corresponding to multiple rounds of string hashing

    # CRC32 is not true hashing but it should be random and uniform
    # enough for our purposes, as well as being quite fast
    def self.crc_bits(str, num_hashes:, num_bits:)
      val = 0
      Array.new(num_hashes) {
        (val = Zlib.crc32(str, val)) % num_bits
      }
    end

    # use either Digest or OpenSSL::Digest (Digest by default)
    # now we are computing MD5, SHA1, etc.
    # these are cryptographic hashes which should be more uniform than
    # CRC32 but not particularly so, and are relatively slow / expensive
    def self.digest_bits(str, num_hashes:, num_bits:, digests: DIGESTS)
      raise "#{num_hashes} hashes" if num_hashes > digests.count
      Array.new(num_hashes) { |i|
        # only consider the LSB 32-bit integer for modulo
        digests[i].digest(str).unpack('N*').last % num_bits
      }
    end

    attr_reader :num_bits, :num_hashes,
                :use_string_hash, :use_crc32, :use_openssl,
                :bitmap

    # The default values require 8 kilobytes of storage and recognize:
    # < 4000 strings; FPR 0.1%
    # < 7000 strings; FPR 1%
    # >  10k strings; FPR 5%
    # The false positive rate goes up as more strings are added
    def initialize(num_bits: 2**16, num_hashes: 5,
                   use_string_hash: true,
                   use_crc32: true,
                   use_openssl: false)
      @num_bits = num_bits
      @num_hashes = num_hashes
      @bitmap = Bitset.new(@num_bits)
      @use_string_hash = use_string_hash
      @use_crc32 = use_crc32
      @use_openssl = use_openssl
    end

    def hash_bits(str)
      @use_crc32 ? crc_bits(str) : digest_bits(str)
    end

    def crc_bits(str)
      if @use_string_hash
        BloomFilter.crc_bits(str,
                             num_hashes: @num_hashes - 1,
                             num_bits: @num_bits).push(str.hash % @num_bits)
      else
        BloomFilter.crc_bits(str, num_hashes: @num_hashes, num_bits: @num_bits)
      end
    end

    def digest_bits(str)
      digests = @use_openssl ? OPENSSL_DIGESTS : DIGESTS
      if @use_string_hash
        BloomFilter.digest_bits(str,
                                num_hashes: @num_hashes - 1,
                                num_bits: @num_bits,
                                digests: digests).push(str.hash % @num_bits)
      else
        BloomFilter.digest_bits(str,
                                num_hashes: @num_hashes,
                                num_bits: @num_bits,
                                digests: digests)
      end
    end

    def add(str)
      @bitmap.set(*self.hash_bits(str))
    end
    alias_method(:<<, :add)

    def include?(str)
      @bitmap.set?(*self.hash_bits(str))
    end

    def likelihood(str)
      self.include?(str) ? 1.0 - self.fpr : 0
    end
    alias_method(:[], :likelihood)

    def percent_full
      @bitmap.to_a.count.to_f / @num_bits
    end

    def fpr
      self.percent_full**@num_hashes
    end

    def estimated_items
      BloomFilter.num_items(@num_bits, @num_hashes, @bitmap.to_a.count)
    end

    def to_s
      format("%i bits (%.1f kB, %i hashes) %i%% full; FPR: %.3f%%",
             @num_bits, @num_bits.to_f / 2**13, @num_hashes,
             self.percent_full * 100, self.fpr * 100)
    end
    alias_method(:inspect, :to_s)
  end

  # reopen the class to provide functions corresponding to the theory
  # of optimal sizing and tuning
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
