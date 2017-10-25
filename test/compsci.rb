require 'compsci'
require 'minitest/autorun'

describe CompSci do
  before do
    @xs = [1, 2, 5, 10, 20, 50, 100, 200, 500]
  end

  it "must sigma" do
    CompSci.sigma([1, 2, 3]).must_equal 6
    CompSci.sigma([1, 2, 3]) { |n| n ** 2 }.must_equal 14
  end

  it "must fit_error" do
    CompSci.fit_error([[1, 1], [2, 2], [3, 3]]) { |x| x }.must_equal 1.0
    CompSci.fit_error([[1, 1], [2, 2], [3, 4]]) { |x| x }.must_be :<, 0.8
  end

  it "must fit_constant" do
    skip "error term for fit_constant needs work / verification"
    a = 100
    @xs += @xs
    ys = @xs.map { |x| a + (rand - 0.5) }
    ary = CompSci.fit_constant(@xs, ys)

    ary[0].must_be_close_to a
    ary[1].must_equal 0
    ary[2].must_be_close_to 1.0
  end

  # y = a + b*ln(x)
  it "must fit_logarithmic" do
    as = [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999]
    bs = [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999]
    as.each { |a|
      bs.each { |b|
        ary = CompSci.fit_logarithmic(@xs, @xs.map { |x| a + b * Math.log(x) })
        ary[0].must_be_close_to a
        ary[1].must_be_close_to b
        ary[2].must_equal 1.0
      }
    }
  end

  # y = a + bx
  it "must fit_linear" do
    as = [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999]
    bs = [-9999, -2000, -500, -0.01, 0.01, 500, 2000, 9999]
    as.each { |a|
      bs.each { |b|
        ary = CompSci.fit_linear(@xs, @xs.map { |x| a + b * x })
        ary[0].must_be_close_to a
        ary[1].must_be_close_to b
        ary[2].must_equal 1.0
      }
    }
  end

  it "must not fit_linear" do
    skip "investigate further"
    # this should be quite un-linear; expect r2 below 0.8
    #
    a = -50
    b = 1.3
    ys = @xs.map { |x| a + b * x**2 + x**3 }
    ary = CompSci.fit_linear(@xs, ys)
    # ary[2].must_be :<, 0.8
    ary[2].must_be :<, 0.9
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
    end
  end

  # y = ae^(bx)
  it "must fit_exponential" do
    as = [0.001, 7.5, 500, 1000, 5000, 9999]
    bs = [-1.4, -1.1, -0.1, 0.01, 0.5, 0.75]
    as.each { |a|
      bs.each { |b|
        ary = CompSci.fit_exponential(@xs,
                                      @xs.map { |x| a * Math::E**(b * x) })
        ary[0].must_be_close_to a
        ary[1].must_be_close_to b
        ary[2].must_equal 1.0
      }
    }
  end

  # y = ax^b
  it "must fit_power" do
    as = [0.01, 7.5, 500, 1000, 5000, 9999]
    bs = [-114, -100, -10, -0.5, -0.1, 0.1, 0.75, 10, 50, 60]
    # -114 causes CompSci.fit_error warning: Bignum out of Float range
    bs.shift
    as.each { |a|
      bs.each { |b|
        ary = CompSci.fit_power(@xs, @xs.map { |x| a * x**b })
        ary[0].must_be_close_to a
        ary[1].must_be_close_to b
        ary[2].must_equal 1.0
      }
    }
  end
end
