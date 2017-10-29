require 'compsci/names'
require 'compsci/names/greek'
require 'minitest/autorun'

include CompSci

describe Names do
  describe "alphabetic constants" do
    it "must have size 26" do
      Names::WW1.size.must_equal 26
      Names::WW2.size.must_equal 26
      Names::NATO.size.must_equal 26
      Names::ENGLISH_UPPER.size.must_equal 26
      Names::ENGLISH_LOWER.size.must_equal 26
    end
  end

  describe "Names.assign" do
    it "must handle English / ASCII strings" do
      upper_lower = Names::ENGLISH_UPPER + Names::ENGLISH_LOWER
      Names.assign('cat', Names::ENGLISH_UPPER).must_equal 'C'
      Names.assign('Cat', Names::ENGLISH_UPPER).must_equal 'C'
      Names.assign('cat', Names::ENGLISH_LOWER).must_equal 'c'
      Names.assign('Cat', Names::ENGLISH_LOWER).must_equal 'c'
      Names.assign('Cat', upper_lower).must_equal 'C'
      Names.assign('cat', upper_lower).must_equal 'c'
      Names.assign('cat', Names::NATO).must_equal :charlie
      Names.assign('Cat', Names::NATO).must_equal :charlie
      Names.assign('Dog', Names::CRYPTO).must_equal :david
      Names.assign('2', Names::PLANETS).must_equal :earth
    end

    it "must handle integers" do
      upper_lower = Names::ENGLISH_UPPER + Names::ENGLISH_LOWER
      Names.assign(36, upper_lower).must_equal 'k'
      Names.assign(0, upper_lower).must_equal 'A'
      Names.assign(0, Names::ENGLISH_UPPER).must_equal 'A'
      Names.assign(3, Names::ENGLISH_LOWER).must_equal 'd'
      Names.assign(3, Names::PLANETS).must_equal :mars
    end
  end

  describe Names::Greek do
    describe "greek alphabetic constants" do
      it "must have size 24" do
        Names::Greek::UPPER.size.must_equal 24
        Names::Greek::LOWER.size.must_equal 24
        Names::Greek::SYMBOLS.size.must_equal 24
        Names::Greek::CHAR_MAP.size.must_equal 24
      end
    end

    describe "SYMBOLS26" do
      it "must work well with Names.assign" do
        s26 = Names::Greek::SYMBOLS26
        Names.assign('iota', s26).must_equal :iota
        Names.assign('jota', s26).must_equal :xi
        Names.assign('Query', s26).must_equal :xi
        Names.assign('who', s26).must_equal :xi
        Names.assign('zeta', s26).must_equal :omega
        Names.assign(0, s26).must_equal :alpha
        Names.assign('1', s26).must_equal :beta
      end
    end
  end

  describe "Greek.sym" do
    it "must handle strings and integers" do
      Names::Greek.sym('cat').must_equal :gamma
      Names::Greek.sym('Cat').must_equal :gamma
      Names::Greek.sym('zeta').must_equal :omega
      Names::Greek.sym(0).must_equal :alpha
      Names::Greek.sym('1').must_equal :beta
      Names::Greek.sym(23).must_equal :omega
    end
  end

  describe "Greek.lower" do
    it "must handle strings and integers" do
      third = Names::Greek::LOWER[2]
      Names::Greek.lower('cat').must_equal third
      Names::Greek.lower('Cat').must_equal third
      Names::Greek.lower(2).must_equal third
      Names::Greek.lower('2').must_equal third
    end
  end

  describe "Greek.upper" do
    it "must handle strings and integers" do
      fourth = Names::Greek::UPPER[3]
      Names::Greek.upper('dog').must_equal fourth
      Names::Greek.upper('Dog').must_equal fourth
      Names::Greek.upper(3).must_equal fourth
      Names::Greek.upper('3').must_equal fourth
    end
  end
end
