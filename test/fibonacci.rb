require 'compsci/fibonacci'
require 'minitest/autorun'

include CompSci

describe Fibonacci do
  before do
    @answers = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
  end

  it "must calculate fib(0..10)" do
    @answers.each_with_index { |ans, i|
      Fibonacci.classic(i).must_equal ans
      Fibonacci.cache_recursive(i).must_equal ans
      Fibonacci.cache_iterative(i).must_equal ans
      Fibonacci.dynamic(i).must_equal ans
      Fibonacci.dynamic_hack(i).must_equal ans
      Fibonacci.matrix(i).must_equal ans
    }
  end
end
