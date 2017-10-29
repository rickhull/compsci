# coding: utf-8

module CompSci
  module Names
    module Greek
      UPPER = [*'Α'..'Ρ', *'Σ'..'Ω']
      LOWER = [*('α'..'ρ'), *('σ'..'ω')]
      SYMBOLS = [:alpha, :beta, :gamma, :delta, :epsilon, :zeta, :eta, :theta,
                 :iota, :kappa, :lambda, :mu, :nu, :xi, :omicron, :pi, :rho,
                 :sigma, :tau, :upsilon, :phi, :chi, :psi, :omega]

      # e.g. { alpha: ['Α', 'α'] ...
      CHAR_MAP = {}
      SYMBOLS.each_with_index { |sym, i| CHAR_MAP[sym] = [UPPER[i], LOWER[i]] }

      LATIN_SYMBOLS = {
        a: :alpha,
        b: :beta,
        c: :gamma,
        d: :delta,
        e: :epsilon,
        f: :zeta,
        g: :eta,
        h: :theta,
        i: :iota,
        j: :xi,      # use for j, q and w
        k: :kappa,
        l: :lambda,
        m: :mu,
        n: :nu,
        # nonesuch: => :xi,
        o: :omicron,
        p: :pi,
        q: :xi,      # use for j, q and w
        r: :rho,
        s: :sigma,
        t: :tau,
        u: :upsilon,
        v: :phi,
        w: :xi,      # use for j, q and w
        x: :chi,
        y: :psi,
        z: :omega,
      }
      SYMBOLS26 = LATIN_SYMBOLS.values

      def self.upper(latin_str)
        CHAR_MAP.fetch(self.sym(latin_str)).first
      end

      def self.lower(latin_str)
        CHAR_MAP.fetch(self.sym(latin_str)).last
      end

      def self.sym(val)
        case val
        when String
          if val.match %r{\A\d+\z}
            # treat positive integer strings as positive integers
            val = val.to_i
            if val >= 0 and val < SYMBOLS.size
              SYMBOLS[val]
            else
              raise "val #{val} not in range (#{SYMBOLS.size})"
            end
          else
            # map the first character to a greek symbol
            LATIN_SYMBOLS.fetch val[0].downcase.to_sym
          end
        when Integer
          if val >= 0 and val < SYMBOLS.size
            # map the integer to a greek symbol
            SYMBOLS[val]
          else
            raise "val #{val} not in range (#{SYMBOLS.size})"
          end
        else
          raise "unexpected val #{val} (#{val.class})"
        end
      end
    end
  end
end
