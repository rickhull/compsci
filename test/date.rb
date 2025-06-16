require 'minitest/autorun'
require 'compsci/date'

D = CompSci::Date

# Edge cases and test data library

# Boundary dates
EPOCH = D.new(1, 1, 1)
MAX_DATE = D.new(9999, 12, 31)

# Common test dates
TEST_DATES = [
  [1, 1, 1],      # epoch
  [4, 2, 29],     # first leap day
  [100, 12, 31],  # non-leap century
  [400, 6, 15],   # leap century
  [1900, 2, 28],  # non-leap century Feb
  [2000, 2, 29],  # leap century Feb
  [2020, 2, 29],  # modern leap day
  [2025, 6, 15],  # current era
  [9999, 12, 31]  # maximum
].map { |y, m, d| D.new(y, m, d) }

# Month name variations for testing
MONTH_VARIATIONS = {
  1 => ['January', 'january', :january],
  2 => ['February', 'february', :february],
  12 => ['December', 'december', :december]
}

describe D do
  describe "leap year calculations" do
    it "identifies leap years" do
      [4, 96, 104, 400, 800, 1200, 1600, 2000, 2020, 2400].each { |leap|
        expect(D.leap_year?(leap)).must_equal true
      }
      [1, 5, 99, 100, 101, 300, 500, 700, 900, 1100, 1900, 2025].each { |year|
        expect(D.leap_year?(year)).must_equal false
      }
    end

    # Century boundaries (special leap year rules)
    it "handles century leap year rules" do
      [400, 800, 1200, 1600, 2000, 2400].each { |leap|
        expect(D.leap_year?(leap)).must_equal true
      }
      [100, 200, 300, 500, 900, 1000, 1100, 1400, 1800, 1900].each { |year|
        expect(D.leap_year?(year)).must_equal false
      }
    end
    
    it "counts leap days, given years-since-epoch" do
      # Key test points
      expect(D.leap_days(3)).must_equal 0
      expect(D.leap_days(4)).must_equal 1
      expect(D.leap_days(100)).must_equal 24  # no leap day for year 100
      expect(D.leap_days(400)).must_equal 97  # includes leap day for year 400
    end
  end
  
  describe "month and day calculations" do
    it "performs month name conversions" do
      MONTH_VARIATIONS.each do |num, names|
        names.each { |name| expect(D.month_number(name)).must_equal num }
        expect(D.month_name(num)).must_equal names.first
      end

      # negative months are support (-11..0)
      expect(D.month_name(0)).must_equal 'December'
      
      # Invalid cases
      expect { D.month_number('invalid') }.must_raise
      expect { D.month_name(13) }.must_raise
    end
  end
  
  describe "date validation and initialization" do
    it "accepts valid boundary dates" do
      expect(EPOCH.to_s).must_equal '0001-01-01'
      expect(MAX_DATE.to_s).must_equal '9999-12-31'
    end
    
    it "rejects invalid boundaries" do
      expect { D.new(0, 1, 1) }.must_raise D::InvalidYear
      expect { D.new(10_000, 1, 1) }.must_raise D::InvalidYear
      expect { D.new(2025, 0, 1) }.must_raise D::InvalidMonth
      expect { D.new(2025, 13, 1) }.must_raise D::InvalidMonth
      expect { D.new(2025, 1, 0) }.must_raise D::InvalidDay
      expect { D.new(2025, 1, 32) }.must_raise D::InvalidDay
    end
    
    it "handles month name initialization" do
      MONTH_VARIATIONS.each { |num, names|
        d = D.new(2025, num, 15)
        names.each { |name| expect(D.new(2025, name, 15)).must_equal d }
      }
    end
    
    it "validates leap day correctly" do
      D.new(2020, 2, 29)                                     # leap year
      expect { D.new(2021, 2, 29) }.must_raise D::InvalidDay # normal year
    end
  end
  
  describe "ordinal day conversions" do
    it "maintains round-trip consistency" do
      TEST_DATES.each do |date|
        reconstructed = D.from_ordinal(date.ordinal_day)
        expect(reconstructed).must_equal date, 
               "Failed round-trip for #{date}: got #{reconstructed}"
      end
    end
    
    it "calculates epoch correctly" do
      expect(EPOCH.ordinal_day).must_equal 1
      expect(D.from_ordinal(1)).must_equal EPOCH
    end
  end
  
  describe "date arithmetic and comparison" do
    it "maintains arithmetic consistency" do
      base_date = D.new(2025, 6, 15)
      [-1000, -365, -31, -1, 0, 1, 31, 365, 1000].each do |days|
        new_date = base_date + days
        expect(new_date - days).must_equal base_date
        expect(new_date.diff(base_date)).must_equal days
      end
    end
    
    it "handles boundary crossings" do
      # Month boundaries
      expect(D.new(2025, 1, 31) + 1).must_equal D.new(2025, 2, 1)
      expect(D.new(2025, 2, 28) + 1).must_equal D.new(2025, 3, 1)
      expect(D.new(2020, 2, 29) + 1).must_equal D.new(2020, 3, 1)
      
      # Year boundaries
      expect(D.new(2024, 12, 31) + 1).must_equal D.new(2025, 1, 1)
      expect(D.new(2025, 1, 1) - 1).must_equal D.new(2024, 12, 31)
    end
    
    it "sorts dates correctly" do
      shuffled = TEST_DATES.shuffle
      sorted = shuffled.sort
      expect(sorted.first).must_equal EPOCH
      expect(sorted.last).must_equal MAX_DATE
    end
  end
  
  describe "formatting and display" do
    it "provides ISO 8601 YYYY-MM-DD format" do
      expect(EPOCH.to_s).must_equal '0001-01-01'
      expect(MAX_DATE.to_s).must_equal '9999-12-31'
      
      # Test padding
      expect(D.new(123, 7, 4).to_s).must_equal '0123-07-04'
    end

    it "provides English long format" do
      expect(EPOCH.name).must_equal 'January 1, 1'
      expect(MAX_DATE.name).must_equal 'December 31, 9999'
    end
  end
  
  describe "leap year edge cases" do
    it "handles century boundaries correctly" do
      # Non-leap century
      expect(D.new(1900, 2, 28) + 1).must_equal D.new(1900, 3, 1)
      expect { D.new(1900, 2, 29) }.must_raise D::InvalidDay
      
      # Leap century  
      expect(D.new(2000, 2, 29) + 1).must_equal D.new(2000, 3, 1)
      D.new(2000, 2, 29)  # should not raise
    end
  end
end
