require 'compsci/fibonacci'
require 'minitest/autorun'

Minitest::Test.parallelize_me!

include CompSci

describe Fibonacci do
  it "must calculate fib(0..10)" do
    [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55].each_with_index { |ans, i|
      [:classic, :cache_recursive, :cache_iterative,
       :dynamic, :matrix].each { |m|
        expect(Fibonacci.send(m, i)).must_equal ans
      }
    }
  end

  it "must match dynamic on big numbers" do
    [500, 1234, 5555, 9999].each { |i|
      [:cache_iterative, :matrix].each { |m|
        expect(Fibonacci.send(m, i)).must_equal Fibonacci.dynamic(i)
      }
    }
  end
end
