require 'compsci/fit'
require 'minitest/autorun'

include CompSci

describe Fit do
  before do
    @xs = [1, 2, 5, 10, 20, 50, 100, 200, 500]
  end

  describe "sigma" do
    it "must answer correctly" do
      Fit.sigma([1, 2, 3]).must_equal 6
      Fit.sigma([1, 2, 3]) { |n| n ** 2 }.must_equal 14
    end
  end

  describe "error" do
    it "must calculate r^2" do
      Fit.error([[1, 1], [2, 2], [3, 3]]) { |x| x }.must_equal 1.0
      Fit.error([[1, 1], [2, 2], [3, 4]]) { |x| x }.must_be_close_to 0.785
    end
  end

  # y = a
  describe "constant" do
    # note, this test can possibly fail depending on the uniformity of
    # rand's output for our sample
    it "must accept constant data" do
      [0, 1, 10, 100, 1000, 9999].each { |a|
        ys = @xs.map { |x| a + (rand - 0.5) }
        y_bar, variance = Fit.constant(@xs, ys)
        var_val = variance / ys.size
        y_bar.must_be_close_to a, 0.3
        var_val.must_be_close_to 0.1, 0.09
      }
    end
  end

  # y = a + b*ln(x)
  describe "logarithmic" do
    it "must accept logarithmic data" do
      [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |a|
        [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |b|
          ary = Fit.logarithmic(@xs, @xs.map { |x| a + b * Math.log(x) })
          ary[0].must_be_close_to a
          ary[1].must_be_close_to b
          ary[2].must_equal 1.0
        }
      }
    end
  end

  # y = a + bx
  describe "linear" do
    it "must accept linear data" do
      [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |a|
        [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |b|
          ary = Fit.linear(@xs, @xs.map { |x| a + b * x })
          ary[0].must_be_close_to a
          ary[1].must_be_close_to b
          ary[2].must_equal 1.0
        }
      }
    end

    # test that b is near 0; (1 - b) is similar magnitude to r2 in terms of
    # threshold
    # here's the deal: r2 is usually pretty low, but sometimes it is up over
    # 0.5, if rand() is being less than uniform in our sample
    # so, accept a wide range for r2
    # and let's check against 1 - b
    #
    # note, this test can possibly fail depending on the uniformity of
    # rand's output for our sample
    #
    it "must accept constant data" do
      r2s = []
      [0, 1, 10, 100, 1000, 9999].each { |a|
        ys = @xs.map { |x| a + (rand - 0.5) }
        ary = Fit.linear(@xs, ys)
        ary[0].must_be_close_to a, 0.4
        ary[1].must_be_close_to 0, 0.05
        r2s << ary[2]
      }
      mean_r2 = Fit.sigma(r2s) / r2s.size
      mean_r2.must_be_close_to 0.15, 0.15
    end

    it "must reject nonlinear data" do
      skip "investigate further"
      # this should be quite un-linear; expect r2 below 0.8
      #
      # ACTUALLY
      #
      # the r2 for fit_linear is mostly about the relative fit of a sloped
      # line compared to zero slope (i.e. y_bar)
      #
      # this is why a linear r2 close to 1.0 is the wrong test for fit_constant
      # because the relative fit of the sloped line (slope near 0) doesn't
      # "explain" much relative to y_bar
      #
      # in the case where y = x^3, a linear fit may still have a high r2,
      # because the error for the y_bar predictor is astronomical.  A super
      # steep slope fits (relative to the zero slope mean) pretty well.

      # this calls into question how useful r2 is, as we need it to be a
      # threshold value due to noise, yet even a terrible fit like trying to
      # match x^3 is hard to distinguish from noise
      #

      a = -50
      b = 1.3
      ys = @xs.map { |x| a + b * x**2 + x**3 }
      ary = Fit.linear(@xs, ys)
      if ary[2] > 0.85
        puts
        puts "fit_linear: #{ary.inspect}"
        puts "y = %0.2f + %0.2f(x) (r2 = %0.3f)" % ary
        puts
        col1, col2 = 5, 15
        puts "x".ljust(col1, ' ') + "y".ljust(col2, ' ') + "predicted"
        puts '---'.ljust(col1, ' ') + '---'.ljust(col2, ' ') + '---'
        @xs.zip(ys).each { |(x,y)|
          puts x.to_s.ljust(col1, ' ') + y.to_s.ljust(col2, ' ') +
               "%0.2f" % (ary[0] + ary[1] * x)
        }
        # ary[2].must_be :<, 0.8
        ary[2].must_be :<, 0.9
      end
    end
  end

  # y = ae^(bx)
  describe "exponential" do
    it "must accept exponential data" do
      [0.001, 7.5, 500, 1000, 5000, 9999].each { |a|
        [-1.4, -1.1, -0.1, 0.01, 0.5, 0.75].each { |b|
          ary = Fit.exponential(@xs, @xs.map { |x| a * Math::E**(b * x) })
          ary[0].must_be_close_to a
          ary[1].must_be_close_to b
          ary[2].must_equal 1.0
        }
      }
    end
  end

  # y = ax^b
  describe "power" do
    it "must accept power data" do
      [0.01, 7.5, 500, 1000, 5000, 9999].each { |a|
        [-114, -100, -10, -0.5, -0.1, 0.1, 0.75, 10, 50, 60].each { |b|
          next if b == -114 # Fit.error warning: Bignum out of Float range
          ary = Fit.power(@xs, @xs.map { |x| a * x**b })
          ary[0].must_be_close_to a
          ary[1].must_be_close_to b
          ary[2].must_equal 1.0
        }
      }
    end
  end
end
