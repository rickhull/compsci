require 'compsci/names'
require 'compsci/names/greek'
require 'compsci/names/pokemon'
require 'minitest/autorun'

include CompSci

describe Names do
  describe "alphabetic constants" do
    it "must have size 26" do
      expect(Names::WW1.size).must_equal 26
      expect(Names::WW2.size).must_equal 26
      expect(Names::NATO.size).must_equal 26
      expect(Names::ENGLISH_UPPER.size).must_equal 26
      expect(Names::ENGLISH_LOWER.size).must_equal 26
    end
  end

  describe "Names.assign" do
    it "must handle English / ASCII strings" do
      upper_lower = Names::ENGLISH_UPPER + Names::ENGLISH_LOWER
      expect(Names.assign('cat', Names::ENGLISH_UPPER)).must_equal 'C'
      expect(Names.assign('Cat', Names::ENGLISH_UPPER)).must_equal 'C'
      expect(Names.assign('cat', Names::ENGLISH_LOWER)).must_equal 'c'
      expect(Names.assign('Cat', Names::ENGLISH_LOWER)).must_equal 'c'
      expect(Names.assign('Cat', upper_lower)).must_equal 'C'
      expect(Names.assign('cat', upper_lower)).must_equal 'c'
      expect(Names.assign('cat', Names::NATO)).must_equal :charlie
      expect(Names.assign('Cat', Names::NATO)).must_equal :charlie
      expect(Names.assign('Dog', Names::CRYPTO)).must_equal :david
      expect(Names.assign('2', Names::PLANETS)).must_equal :earth end

    it "must handle integers" do
      upper_lower = Names::ENGLISH_UPPER + Names::ENGLISH_LOWER
      expect(Names.assign(36, upper_lower)).must_equal 'k'
      expect(Names.assign(0, upper_lower)).must_equal 'A'
      expect(Names.assign(0, Names::ENGLISH_UPPER)).must_equal 'A'
      expect(Names.assign(3, Names::ENGLISH_LOWER)).must_equal 'd'
      expect(Names.assign(3, Names::PLANETS)).must_equal :mars
    end
  end

  describe Names::Greek do
    describe "greek alphabetic constants" do
      it "must have size 24" do
        expect(Names::Greek::UPPER.size).must_equal 24
        expect(Names::Greek::LOWER.size).must_equal 24
        expect(Names::Greek::SYMBOLS.size).must_equal 24
        expect(Names::Greek::CHAR_MAP.size).must_equal 24
      end
    end

    describe "SYMBOLS26" do
      it "must work well with Names.assign" do
        s26 = Names::Greek::SYMBOLS26
        expect(Names.assign('iota', s26)).must_equal :iota
        expect(Names.assign('jota', s26)).must_equal :xi
        expect(Names.assign('Query', s26)).must_equal :xi
        expect(Names.assign('who', s26)).must_equal :xi
        expect(Names.assign('zeta', s26)).must_equal :omega
        expect(Names.assign(0, s26)).must_equal :alpha
        expect(Names.assign('1', s26)).must_equal :beta
      end
    end

    describe "Greek.sym" do
      it "must handle strings and integers" do
        expect(Names::Greek.sym('cat')).must_equal :gamma
        expect(Names::Greek.sym('Cat')).must_equal :gamma
        expect(Names::Greek.sym('zeta')).must_equal :omega
        expect(Names::Greek.sym(0)).must_equal :alpha
        expect(Names::Greek.sym('1')).must_equal :beta
        expect(Names::Greek.sym(23)).must_equal :omega
      end
    end

    describe "Greek.lower" do
      it "must handle strings and integers" do
        third = Names::Greek::LOWER[2]
        expect(Names::Greek.lower('cat')).must_equal third
        expect(Names::Greek.lower('Cat')).must_equal third
        expect(Names::Greek.lower(2)).must_equal third
        expect(Names::Greek.lower('2')).must_equal third
      end
    end

    describe "Greek.upper" do
      it "must handle strings and integers" do
        fourth = Names::Greek::UPPER[3]
        expect(Names::Greek.upper('dog')).must_equal fourth
        expect(Names::Greek.upper('Dog')).must_equal fourth
        expect(Names::Greek.upper(3)).must_equal fourth
        expect(Names::Greek.upper('3')).must_equal fourth
      end
    end
  end

  describe Names::Pokemon do
    it "must have an array" do
      ary = Names::Pokemon.array
      expect(ary).must_be_kind_of Array
      expect(ary.size).must_be :>, 99
    end

    it "must have a hash keyed by first letter" do
      hsh = Names::Pokemon.hash
      expect(hsh).must_be_kind_of Hash
      expect(hsh.size).must_equal 26
      expect(hsh['n']).must_be_kind_of Array
      expect(hsh['n'].first).must_be_kind_of String
      expect(hsh['n'].first).must_match(/^n/)
    end

    it "must grep for charizard" do
      ary = Names::Pokemon.grep(/^char/, all: true)
      expect(ary).must_include 'charizard'
      char = Names::Pokemon.grep(/^char/, all: false)
      expect(char).wont_equal 'charizard'
      expect(char).must_equal 'charmander'
    end

    it "must convert vals to key letters" do
      [5, '5', 'food', 'Food'].each { |valid|
        expect(Names::Pokemon.key(valid)).must_equal 'f'
      }

      ['---', Names::Pokemon].each { |invalid_raise|
        expect(proc { Names::Pokemon.key(invalid_raise) }).must_raise Exception
      }

      [4359873548].each { |invalid_nil|
        expect(Names::Pokemon.key(invalid_nil).nil?).must_equal true
      }
    end
  end
end
