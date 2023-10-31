require 'compsci/collatz'
require 'minitest/autorun'

include CompSci

describe Collatz do
  it "performs the Collatz operation on any positive integer" do
    # n/2 if n is even, 3n+1 otherwise
    { 2 => 1,
      3 => 10,
      4 => 2,
      5 => 16,
      6 => 3,
      7 => 22,
      8 => 4,
      9 => 28,
    }.each { |input, output|
      expect(Collatz.once(input)).must_equal output
    }
  end

  it "can loop output to input until output is 1" do
    register = Collatz.loop(99)
    expect(register).must_be_kind_of Hash
    expect(register).wont_be_empty
    expect(register.size).must_be :>, 20 # it is known
    expect(register.size).must_be :<, 50
    expect(register[99]).must_equal 1
    expect(register[2]).must_equal 1
  end
end
