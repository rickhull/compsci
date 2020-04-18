require 'compsci/fibonacci'
require 'minitest/autorun'

Minitest::Test.parallelize_me!

include CompSci

describe Fibonacci do
  before do
    @answers = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
  end

  it "must calculate fib(0..10)" do
    @answers.each_with_index { |ans, i|
      [:classic, :cache_recursive, :cache_iterative,
       :dynamic, :matrix].each { |m|
        expect(Fibonacci.send(m, i)).must_equal ans
      }
    }
  end
end
