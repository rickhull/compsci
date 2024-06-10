require 'minitest/autorun'
require 'compsci/elo'

include CompSci

describe Elo do
  it "is configured with 3 variables: initial, k, and c" do
    # ntoe, these values are not very sensible
    e = Elo.new(initial: 5, k: 10, c: 15)
    expect(e.initial).must_equal 5
    expect(e.k).must_equal 10
    expect(e.c).must_equal 15
  end

  it "has sensible defaults" do
    e = Elo.new
    expect(e.initial).must_be :<=, 99999
    expect(e.initial).must_be :>=, 100
    expect(e.k).must_be :<=, 100
    expect(e.k).must_be :>=, 5
    expect(e.c).must_be :<=, 1000
    expect(e.c).must_be :>=, 100
  end

  it "calculates an expected score, given a matchup with two ratings" do
    e = Elo.new
    score = e.expected(500, 500)
    expect(score).must_equal 0.5
    expect(e.expected(1000, 500)).must_be :>, 0.5
    expect(e.expected(500, 1000)).must_be :<, 0.5
    expect(e.expected(1500, 1400)).must_be :>, 0.5
  end

  it "updates ratings given the outcome of a match" do
    e = Elo.new
    a = 800
    b = 1000

    # win for a; increases a's rating and decreases b's
    new_a, new_b = e.update(a, b, 1)
    expect(new_a).must_be :>, a
    expect(new_b).must_be :<, b

    # draw increases a's rating and decreases b's
    new_a2, new_b2 = e.update(new_a, new_b, 0.5)
    expect(new_a2).must_be :>, new_a
    expect(new_b2).must_be :<, new_b

    # draw increase is smaller than win increase
    expect(new_a2 - new_a).must_be :<, (new_a - a)
    expect(new_b - new_b2).must_be :<, (b - new_b)

    # loss for a; decreases a's rating and icreases b's
    new_a3, new_b3 = e.update(new_a2, new_b2, 0)
    expect(new_a3).must_be :<, new_a2
    expect(new_b3).must_be :>, new_b2
  end

  it "provides a CLASSIC configuration" do
    expect(Elo::CLASSIC).must_be_kind_of Elo
    expect(Elo::CLASSIC.initial).must_equal 1500
    expect(Elo::CLASSIC.k).must_equal 32
    expect(Elo::CLASSIC.c).must_equal 400
  end

  it "has class methods that use the classic configuration" do
    expect(Elo.expected(500, 1000)).must_be :<, 0.5
    expect(Elo.expected(750, 750)).must_equal 0.5
    expect(Elo.expected(1000, 500)).must_be :>, 0.5

    a, b = Elo.update(500, 1000, 1)
    expect(a).must_be :>, 500
    expect(b).must_be :<, 1000
  end

  describe Elo::Player do
    it "must be initialized with an Elo object" do
      expect { Elo::Player.new }.must_raise ArgumentError
      expect { Elo::Player.new(1234) }.must_raise ArgumentError
      expect(Elo::Player.new(Elo.new)).must_be_kind_of Elo::Player
    end
  end
end
