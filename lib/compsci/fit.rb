module CompSci
  module Fit
    #
    # functions below originally from https://github.com/seattlrb/minitest
    #

    ##
    # Enumerates over +enum+ mapping +block+ if given, returning the
    # sum of the result. Eg:
    #
    #   sigma([1, 2, 3])                # => 1 + 2 + 3 => 6
    #   sigma([1, 2, 3]) { |n| n ** 2 } # => 1 + 4 + 9 => 14

    def self.sigma enum, &block
      enum = enum.map(&block) if block
      enum.inject { |sum, n| sum + n }
    end

    ##
    # Takes an array of x/y pairs and calculates the general R^2 value to
    # measure fit against a predictive function,  which is the block supplied
    # to error:
    #
    # e.g. error(xys) { |x| 5 + 2 * x }
    #
    # See: http://en.wikipedia.org/wiki/Coefficient_of_determination
    #

    def self.error xys, &blk
      y_bar  = sigma(xys) { |_, y| y                   } / xys.size.to_f
      ss_tot = sigma(xys) { |_, y| (y - y_bar)    ** 2 }
      ss_res = sigma(xys) { |x, y| (yield(x) - y) ** 2 }

      1 - (ss_res / ss_tot)
    end

    ##
    # Fits the functional form: a (+ 0x)
    #
    # Takes x and y values and returns [a, variance]
    #

    def self.constant xs, ys
      # written by Rick
      y_bar = sigma(ys) / ys.size.to_f
      variance = sigma(ys) { |y| (y - y_bar) ** 2 }
      [y_bar, variance]
    end

    ##
    # To fit a functional form: y = a + b*ln(x).
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingLogarithmic.html

    def self.logarithmic xs, ys
      n     = xs.size
      xys   = xs.zip(ys)
      slnx2 = sigma(xys) { |x, _| Math.log(x) ** 2 }
      slnx  = sigma(xys) { |x, _| Math.log(x)      }
      sylnx = sigma(xys) { |x, y| y * Math.log(x)  }
      sy    = sigma(xys) { |_, y| y                }

      c = n * slnx2 - slnx ** 2
      b = ( n * sylnx - sy * slnx ) / c
      a = (sy - b * slnx) / n

      return a, b, self.error(xys) { |x| a + b * Math.log(x) }
    end

    ##
    # Fits the functional form: a + bx.
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFitting.html

    def self.linear xs, ys
      n   = xs.size
      xys = xs.zip(ys)
      sx  = sigma xs
      sy  = sigma ys
      sx2 = sigma(xs)  { |x|   x ** 2 }
      sxy = sigma(xys) { |x, y| x * y  }

      c = n * sx2 - sx**2
      a = (sy * sx2 - sx * sxy) / c
      b = ( n * sxy - sx * sy ) / c

      return a, b, self.error(xys) { |x| a + b * x }
    end

    ##
    # To fit a functional form: y = ae^(bx).
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

    def self.exponential xs, ys
      n     = xs.size
      xys   = xs.zip(ys)
      sxlny = sigma(xys) { |x, y| x * Math.log(y) }
      slny  = sigma(xys) { |_, y| Math.log(y)     }
      sx2   = sigma(xys) { |x, _| x * x           }
      sx    = sigma xs

      c = n * sx2 - sx ** 2
      a = (slny * sx2 - sx * sxlny) / c
      b = ( n * sxlny - sx * slny ) / c

      return Math.exp(a), b, self.error(xys) { |x| Math.exp(a + b * x) }
    end

    ##
    # To fit a functional form: y = ax^b.
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingPowerLaw.html

    def self.power xs, ys
      n       = xs.size
      xys     = xs.zip(ys)
      slnxlny = sigma(xys) { |x, y| Math.log(x) * Math.log(y) }
      slnx    = sigma(xs)  { |x   | Math.log(x)               }
      slny    = sigma(ys)  { |   y| Math.log(y)               }
      slnx2   = sigma(xs)  { |x   | Math.log(x) ** 2          }

      b = (n * slnxlny - slnx * slny) / (n * slnx2 - slnx ** 2)
      a = (slny - b * slnx) / n

      return Math.exp(a), b, self.error(xys) { |x| (Math.exp(a) * (x ** b)) }
    end
  end
end
