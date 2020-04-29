require 'compsci/fit'
require 'minitest/autorun'

Minitest::Test.parallelize_me!

include CompSci

def noise # range: -0.5 to 0.5
  rand - 0.5
end

describe Fit do
  before do
    @xs = [1, 2, 5, 10, 20, 50, 100, 200, 500]
  end

  describe "Fit.sigma" do
    it "must answer correctly" do
      expect(Fit.sigma([1, 2, 3])).must_equal 6
      expect(Fit.sigma([1, 2, 3]) { |n| n ** 2 }).must_equal 14
    end
  end

  describe "Fit.error" do
    it "must calculate r^2" do
      expect(Fit.error([[1, 1], [2, 2], [3, 3]]) { |x| x }).must_equal 1.0
      expect(Fit.error([[1, 1], [2, 2], [3, 4]]) { |x|
               x
             }).must_be_close_to 0.785
    end
  end

  # y = a
  # Note: Thinking about dropping this.
  #       I don't know how to test the variance for constantness or any
  #       alternate measure.  A low slope and r2 for linear fit, maybe.
  #
  describe "Fit.constant" do
    it "must stuff" do
      [0, 1, 10, 100, 1000, 9999].each { |a|
        y_bar, variance = Fit.constant(@xs, @xs.map { |x| a })
        expect(y_bar).must_equal a
        expect(variance).must_equal 0
      }
    end
  end

  # y = a + b*ln(x)
  describe "Fit.logarithmic" do
    it "must accept logarithmic data" do
      [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |a|
        [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |b|
          ary = Fit.logarithmic(@xs, @xs.map { |x| a + b * Math.log(x) })
          expect(ary[0]).must_be_close_to a
          expect(ary[1]).must_be_close_to b
          expect(ary[2]).must_equal 1.0
        }
      }
    end
  end

  # y = a + bx
  describe "Fit.linear" do
    it "must accept linear data" do
      [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |a|
        [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999].each { |b|
          ary = Fit.linear(@xs, @xs.map { |x| a + b * x })
          expect(ary[0]).must_be_close_to a
          expect(ary[1]).must_be_close_to b
          expect(ary[2]).must_equal 1.0
        }
      }
    end

    it "must accept constant data" do
      [0, 1, 10, 100, 1000, 9999].each { |a|
        ary = Fit.linear(@xs, @xs.map { |x| a })
        expect(ary[0]).must_equal a
        expect(ary[1]).must_equal 0
        expect(ary[2].nan?).must_equal true
      }
    end

    # note, this test can possibly fail depending on the uniformity of
    # rand's output for our sample
    #
    it "must accept noisy constant data" do
      r2s = []
      [0, 1, 10, 100, 1000, 9999].each { |a|
        ary = Fit.linear(@xs, @xs.map { |x| a + noise() })
        expect(ary[0]).must_be_close_to a, 0.4
        expect(ary[1]).must_be_close_to 0, 0.05
        r2s << ary[2]
      }
      mean_r2 = Fit.sigma(r2s) / r2s.size
      expect(mean_r2).must_be_close_to 0.15, 0.15
    end

    it "must reject x^2" do
      skip "it does not reject x^2 at r^2 < 0.99"
      xs = [1, 10, 100, 1000]
      _a, _b, r2 = Fit.linear(xs, xs.map { |x| x**2 })
      expect(r2).must_be :<, 0.99
    end

    it "must reject x^3" do
      skip "it does not reject x^3 at r^2 < 0.99"
      xs = [1, 10, 100, 1000]
      _a, _b, r2 = Fit.linear(xs, xs.map { |x| x**3 })
      expect(r2).must_be :<, 0.99
    end
  end

  # y = ae^(bx)
  describe "Fit.exponential" do
    it "must accept exponential data" do
      [0.001, 7.5, 500, 1000, 5000, 9999].each { |a|
        [-1.4, -1.1, -0.1, 0.01, 0.5, 0.75].each { |b|
          ary = Fit.exponential(@xs, @xs.map { |x| a * Math::E**(b * x) })
          expect(ary[0]).must_be_close_to a
          expect(ary[1]).must_be_close_to b
          expect(ary[2]).must_equal 1.0
        }
      }
    end
  end

  # y = ax^b
  describe "Fit.power" do
    it "must accept power data" do
      [0.01, 7.5, 500, 1000, 5000, 9999].each { |a|
        [-114, -100, -10, -0.5, -0.1, 0.1, 0.75, 10, 50, 60].each { |b|
          next if b == -114 # Fit.error warning: Bignum out of Float range
          ary = Fit.power(@xs, @xs.map { |x| a * x**b })
          expect(ary[0]).must_be_close_to a
          expect(ary[1]).must_be_close_to b
          expect(ary[2]).must_equal 1.0
        }
      }
    end
  end
end
