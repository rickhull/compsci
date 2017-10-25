require 'compsci/fib'
require 'minitest/autorun'

include CompSci

describe Fibonacci do
  it "must calculate fib(10) == 55" do
    Fibonacci.classic(10).must_equal 55
    Fibonacci.cache_recursive(10).must_equal 55
    Fibonacci.cache_iterative(10).must_equal 55
    Fibonacci.dynamic(10).must_equal 55
  end
end
