require 'minitest/autorun'
require 'compsci/elo'

include CompSci

describe Elo do
  it "is configured with 3 variables: initial, k, and c" do
    # note, these values are not very sensible
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
    it "has sensible defaults" do
      expect(Elo::Player.new).must_be_kind_of Elo::Player
    end

    it "may be initialized with an Elo object" do
      expect(Elo::Player.new(elo: Elo.new)).must_be_kind_of Elo::Player
    end

    it "is Comparable, based on Elo rating" do
      a = Elo::Player.new
      b = Elo::Player.new

      expect(a <=> b).must_equal 0
      a.rating = 2 * b.rating
      expect(a <=> b).must_equal 1
      b.rating = a.rating + 1
      expect(a <=> b).must_equal(-1)

      a.rating = b.rating
      expect(a == b).must_equal true
      expect(a == a).must_equal true
      expect(a != b).must_equal false

      a.rating = b.rating + 1
      expect(a > b).must_equal true
    end

    it "can initialize a pool of players" do
      pool = Elo::Player.init_pool(99)
      expect(pool).must_be_kind_of Array
      pool.each { |player| player.rating = rand(2000) }
      sorted = pool.sort # sorts on rating because of <=> and Comparable
      expect(sorted.first.rating).must_be :<, sorted.last.rating
    end

    it "updates both self and opponent with a match outcome" do
      a = Elo::Player.new
      b = Elo::Player.new

      # 5 wins for _a_
      5.times { a.update(b, 1) }

      expect(a > b).must_equal true

      a_rating, b_rating = a.rating, b.rating

      # a draw, _a_'s rating goes down, _b_'s goes up
      a.update(b, 0.5)
      expect(a.rating).must_be :<, a_rating
      expect(b.rating).must_be :>, b_rating
    end

    it "can perform skill-based match simulations" do
      a = Elo::Player.new(skill: 0.95)
      b = Elo::Player.new(skill: 0.3)

      expect(a == b).must_equal true   # ratings are the same

      # 99 matches
      99.times { a.simulate(b) }
      expect(a > b).must_equal true    # a's rating should increase
    end
  end
end
