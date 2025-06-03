require 'minitest/autorun'
require 'compsci/date'

# include CompSci
D = CompSci::Date

describe D do
  describe "class functions" do
    it "determines whether any positive year is a leap year" do
      # 0 is not valid but the function will accept it
      expect(D.leap_year? 0).must_equal true
      expect(D.leap_year? 1).must_equal false
      expect(D.leap_year? 4).must_equal true
      expect(D.leap_year? 5).must_equal false
      expect(D.leap_year? 96).must_equal true
      expect(D.leap_year? 99).must_equal false
      expect(D.leap_year? 100).must_equal false
      expect(D.leap_year? 101).must_equal false
      expect(D.leap_year? 104).must_equal true
      expect(D.leap_year? 399).must_equal false
      expect(D.leap_year? 400).must_equal true
      expect(D.leap_year? 500).must_equal false
      expect(D.leap_year? 600).must_equal false
      expect(D.leap_year? 700).must_equal false
    end

    it "counts the number of leaps days in a number of years since epoch" do
      # 0 is not valid but the function will accept it
      expect(D.leap_days 0).must_equal 0
      expect(D.leap_days 1).must_equal 0
      expect(D.leap_days 3).must_equal 0
      expect(D.leap_days 4).must_equal 1
      expect(D.leap_days 5).must_equal 1
      expect(D.leap_days 8).must_equal 2
      expect(D.leap_days 99).must_equal 24
      expect(D.leap_days 100).must_equal 24
      expect(D.leap_days 101).must_equal 24
    end

    it "determines the number of days in any given year" do
      # 0 is not valid but the function will accept it
      expect(D.annual_days 0).must_equal 366
      expect(D.annual_days 1).must_equal 365
      expect(D.annual_days 2).must_equal 365
      expect(D.annual_days 3).must_equal 365
      expect(D.annual_days 4).must_equal 366
      expect(D.annual_days 5).must_equal 365
    end

    it "looks up month names by month number" do
      # 0 is not valid but the function will accept it
      expect(D.month_name 0).must_equal 'December'
      expect(D.month_name 1).must_equal 'January'
      expect(D.month_name 12).must_equal 'December'
      expect { D.month_name 13 }.must_raise
    end

    it "looks up month number by month name" do
      expect { D.month_number 'nevermore' }.must_raise
      expect(D.month_number :january).must_equal 1
      expect(D.month_number 'february').must_equal 2
      expect(D.month_number 'March').must_equal 3
    end

    it "looks up the number of days in any given month and year" do
      # non-leap year
      expect(D.month_days(1, 2025)).must_equal 31
      expect(D.month_days(2, 2025)).must_equal 28
      expect(D.month_days(3, 2025)).must_equal 31
      expect(D.month_days(4, 2025)).must_equal 30
      expect(D.month_days(12, 2025)).must_equal 31
      
      # leap year
      expect(D.month_days(1, 2020)).must_equal 31
      expect(D.month_days(2, 2020)).must_equal 29
      expect(D.month_days(3, 2020)).must_equal 31
      expect(D.month_days(4, 2020)).must_equal 30
      expect(D.month_days(12, 2020)).must_equal 31
    end

    it "looks up accumulated annual days for a given month and year" do
      # january is always 0
      expect(D.cumulative_days(1, 2025)).must_equal 0
      expect(D.cumulative_days(1, 2020)).must_equal 0

      # february is always 31
      expect(D.cumulative_days(2, 2025)).must_equal 31
      expect(D.cumulative_days(2, 2020)).must_equal 31

      # march-december can vary +1 on leap year
      expect(D.cumulative_days(3, 2025)).must_equal 31 + 28
      expect(D.cumulative_days(3, 2020)).must_equal 31 + 29

      expect(D.cumulative_days(12, 2025)).must_equal D::ANNUAL_DAYS - 31
      expect(D.cumulative_days(12, 2020)).must_equal D::ANNUAL_DAYS - 30
    end

    it "converts year, month, day to a day count since epoch" do
      expect(D.day_count(1, 1, 1)).must_equal 1
      expect(D.day_count(1, 1, 2)).must_equal 2
      expect(D.day_count(1, 1, 31)).must_equal 31
      expect(D.day_count(1, 2, 1)).must_equal 31 + 1
      expect(D.day_count(1, 3, 1)).must_equal 31 + 28 + 1

      # (1=normal year)
      feb1 = D.day_count(1, 2, 1)
      mar1 = D.day_count(1, 3, 1)
      expect(mar1 - feb1).must_equal 28

      # (4=leap year)
      feb1 = D.day_count(4, 2, 1)
      mar1 = D.day_count(4, 3, 1)
      expect(mar1 - feb1).must_equal 29
    end

    it "converts a day count since epoch into a Date" do
      expect(D.from_days(1)).must_equal D.new(1, 1, 1)
      expect(D.from_days(2)).must_equal D.new(1, 1, 2)
      expect(D.from_days(31)).must_equal D.new(1, 1, 31)
      expect(D.from_days(32)).must_equal D.new(1, 2, 1)
      expect(D.from_days(31 + 29)).must_equal D.new(1, 3, 1)
    end
  end

  describe "initialization and validation" do
    it "initializes with 3 integers: year, month, day" do
      d = D.new(1, 1, 1)
      k = D.new(year: 1, month: 1, day: 1)
      expect(d).must_equal k
    end

    it "initializes with month names as strings or symbols" do
      d1 = D.new(2025, 'January', 15)
      d2 = D.new(2025, :january, 15)
      d3 = D.new(2025, 1, 15)
      expect(d1).must_equal d3
      expect(d2).must_equal d3
    end

    it "validates year range" do
      expect { D.new(0, 1, 1) }.must_raise D::InvalidYear
      expect { D.new(10000, 1, 1) }.must_raise D::InvalidYear
      # valid years should work
      D.new(1, 1, 1)
      D.new(9999, 12, 31)
    end

    it "validates month range and format" do
      expect { D.new(2025, 0, 1) }.must_raise D::InvalidMonth
      expect { D.new(2025, 13, 1) }.must_raise D::InvalidMonth
      expect { D.new(2025, 'invalid', 1) }.must_raise D::InvalidMonth
      expect { D.new(2025, :invalid, 1) }.must_raise D::InvalidMonth
    end

    it "validates day range for each month" do
      # January (31 days)
      D.new(2025, 1, 31)
      expect { D.new(2025, 1, 32) }.must_raise D::InvalidDay
      
      # February non-leap year (28 days)
      D.new(2025, 2, 28)
      expect { D.new(2025, 2, 29) }.must_raise D::InvalidDay
      
      # February leap year (29 days)
      D.new(2020, 2, 29)
      expect { D.new(2020, 2, 30) }.must_raise D::InvalidDay
      
      # April (30 days)
      D.new(2025, 4, 30)
      expect { D.new(2025, 4, 31) }.must_raise D::InvalidDay
      
      # Invalid day 0
      expect { D.new(2025, 1, 0) }.must_raise D::InvalidDay
    end
  end

  describe "instance methods" do
    it "answers whether it is a leap year" do
      expect(D.new(1, 1, 1).leap_year?).must_equal false
      expect(D.new(4, 1, 1).leap_year?).must_equal true
      expect(D.new(2020, 1, 1).leap_year?).must_equal true
      expect(D.new(2025, 1, 1).leap_year?).must_equal false
    end

    it "provides access to day_count" do
      d1 = D.new(1, 1, 1)
      d2 = D.new(1, 1, 2)
      expect(d1.day_count).must_equal 1
      expect(d2.day_count).must_equal 2
    end

    it "formats as ISO date string" do
      expect(D.new(1, 1, 1).to_s).must_equal '0001-01-01'
      expect(D.new(2025, 12, 31).to_s).must_equal '2025-12-31'
      expect(D.new(123, 7, 4).to_s).must_equal '0123-07-04'
    end

    it "formats as readable name" do
      expect(D.new(1, 1, 1).name).must_equal 'January 1, 1'
      expect(D.new(2025, 12, 31).name).must_equal 'December 31, 2025'
      expect(D.new(2020, 2, 29).name).must_equal 'February 29, 2020'
    end
  end

  describe "comparison and ordering" do
    it "compares dates correctly" do
      d1 = D.new(2025, 1, 1)
      d2 = D.new(2025, 1, 2)
      d3 = D.new(2025, 2, 1)
      d4 = D.new(2026, 1, 1)
      
      expect(d1 < d2).must_equal true
      expect(d2 < d3).must_equal true
      expect(d3 < d4).must_equal true
      expect(d1 < d4).must_equal true
      
      expect(d2 > d1).must_equal true
      expect(d4 > d1).must_equal true
      
      expect(d1 == D.new(2025, 1, 1)).must_equal true
      expect(d1 != d2).must_equal true
    end

    it "sorts dates correctly" do
      dates = [
        D.new(2025, 12, 31),
        D.new(2025, 1, 1),
        D.new(2024, 12, 31),
        D.new(2025, 6, 15)
      ]
      
      sorted = dates.sort
      expect(sorted.first).must_equal D.new(2024, 12, 31)
      expect(sorted.last).must_equal D.new(2025, 12, 31)
    end
  end

  describe "date arithmetic" do
    it "adds days correctly" do
      d = D.new(2025, 1, 1)
      expect(d + 0).must_equal d
      expect(d + 1).must_equal D.new(2025, 1, 2)
      expect(d + 31).must_equal D.new(2025, 2, 1)
      expect(d + 365).must_equal D.new(2026, 1, 1)
    end

    it "subtracts days correctly" do
      d = D.new(2025, 2, 1)
      expect(d - 0).must_equal d
      expect(d - 1).must_equal D.new(2025, 1, 31)
      expect(d - 31).must_equal D.new(2025, 1, 1)
    end

    it "handles month boundaries correctly" do
      # End of January to February
      jan31 = D.new(2025, 1, 31)
      expect(jan31 + 1).must_equal D.new(2025, 2, 1)
      
      # End of February (non-leap) to March
      feb28 = D.new(2025, 2, 28)
      expect(feb28 + 1).must_equal D.new(2025, 3, 1)
      
      # End of February (leap) to March
      feb29 = D.new(2020, 2, 29)
      expect(feb29 + 1).must_equal D.new(2020, 3, 1)
    end

    it "handles year boundaries correctly" do
      dec31 = D.new(2024, 12, 31)
      expect(dec31 + 1).must_equal D.new(2025, 1, 1)
      
      jan1 = D.new(2025, 1, 1)
      expect(jan1 - 1).must_equal D.new(2024, 12, 31)
    end

    it "handles large day additions and subtractions" do
      d = D.new(2020, 1, 1)
      
      # Add multiple years worth of days
      # +1 for leap day
      expect(d + (365 * 4 + 1)).must_equal D.new(2024, 1, 1)
      
      # Subtract to go back years
      d2 = D.new(2026, 1, 1)
      expect(d2 - 365).must_equal D.new(2025, 1, 1)
      # includes leap day
      d3 = D.new(2025, 1, 1)
      expect(d3 - 366).must_equal D.new(2024, 1, 1)
    end

    it "calculates differences between dates" do
      d1 = D.new(2025, 1, 1)
      d2 = D.new(2025, 1, 2)
      d3 = D.new(2025, 2, 1)
      
      expect(d2.diff(d1)).must_equal 1
      expect(d1.diff(d2)).must_equal(-1)
      expect(d3.diff(d1)).must_equal 31
      expect(d1.diff(d3)).must_equal(-31)
    end
  end

  describe "round-trip consistency" do
    it "maintains consistency between day_count and from_days" do
      dates = [
        D.new(1, 1, 1),
        D.new(4, 2, 29),  # leap day
        D.new(100, 12, 31),
        D.new(400, 6, 15),
        D.new(2025, 1, 1),
        D.new(9999, 12, 31)
      ]
      
      dates.each do |date|
        reconstructed = D.from_days(date.day_count)
        expect(reconstructed).must_equal date
      end
    end

    it "maintains consistency with date arithmetic" do
      base_date = D.new(2025, 6, 15)
      
      [-1000, -365, -31, -1, 0, 1, 31, 365, 1000].each do |days|
        new_date = base_date + days
        expect(new_date - days).must_equal base_date
        expect(new_date.diff(base_date)).must_equal days
      end
    end
  end

  describe "edge cases" do
    it "handles leap year edge cases correctly" do
      # Century years that are not leap years
      expect(D.new(1900, 2, 28) + 1).must_equal D.new(1900, 3, 1)
      
      # Century years that are leap years
      expect(D.new(2000, 2, 29) + 1).must_equal D.new(2000, 3, 1)
    end

    it "handles epoch boundary" do
      epoch = D.new(1, 1, 1)
      expect(epoch.day_count).must_equal 1
      expect(D.from_days(1)).must_equal epoch
    end

    it "handles maximum valid date" do
      max_date = D.new(9999, 12, 31)
      expect(max_date.to_s).must_equal '9999-12-31'
      expect(max_date.name).must_equal 'December 31, 9999'
    end
  end
end
