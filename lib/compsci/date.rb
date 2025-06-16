# This library implements a proleptic Gregorian calendar:
# ---
# The Julian-Gregorian transition in 1582 is ignored
# The Gregorian calendar extends backwards to year 1
# The epoch is 0001-01-01

module CompSci
  class Date < Data.define(:year, :month, :day)
    class InvalidYear < RuntimeError; end
    class InvalidMonth < RuntimeError; end
    class InvalidDay < RuntimeError; end
    class NegativeError < RuntimeError; end
    
    include Comparable

    #
    # Leap Years
    #

    # this is the crux of the Gregorian calendar
    def self.leap_year?(year)
      (year % 4).zero? and !(year % 100).zero? or (year % 400).zero?
    end

    # cumulative leap days from year 1 up to and including _year_
    def self.leap_days(year)
      return 0 if year <= 3
      (year / 4) - (year / 100) + (year / 400)
    end

    #
    # Definitions
    #

    # define month lengths
    MON31 = 31 # Jan, Mar, May, Jul, Aug, Oct, Dec
    MON30 = 30 # Apr, Jun, Sep, Nov
    MON29 = 29 # Feb (leap)
    MON28 = 28 # Feb

    # define lookup by month number, zero-indexed
    MONTH_DAYS =
      [MON31, MON28, MON31, MON30, MON31, MON30,
       MON31, MON31, MON30, MON31, MON30, MON31].freeze

    # derive CUMULATIVE_DAYS from MONTH_DAYS, zero-indexed
    CUMULATIVE_DAYS = MONTH_DAYS.reduce([0]) { |acc, days|
      acc + [acc.last + days]
    } # [0, 31, 59, 90, 120, ... 334, 365]
    ANNUAL_DAYS = CUMULATIVE_DAYS.pop  # 365
    LEAP_YEAR_DAYS = ANNUAL_DAYS + 1   # 366
    CUMULATIVE_DAYS.freeze

    # derive CUMULATIVE_LEAP_DAYS from CUMULATIVE_DAYS, zero-indexed
    CUMULATIVE_LEAP_DAYS = CUMULATIVE_DAYS.map.with_index { |days, i|
      i < 2 ? days : days + 1
    }.freeze # [0, 31, 60, 91, 121, ... 335]
    
    # implementation considerations
    MIN_Y, MIN_M, MIN_D = 1, 1, 1
    MAX_Y, MAX_M, MAX_D = 9999, MONTH_DAYS.size, MON31

    DAYS_400 = 146097 # self.year_days(400)
    DAYS_100 = 36524  # self.year_days(100)
    DAYS_4   = 1461   # self.year_days(4)


    # currently unused
    # EPOCH_Y, EPOCH_M, EPOCH_D = 1, 1, 1
    MEAN_ANNUAL_DAYS = 365.2425 # DAYS_400 / 400.0
    # MEAN_MONTH_DAYS = MEAN_ANNUAL_DAYS / NUM_MONTHS

    #
    # Functions
    #

    # how many days in the years since epoch
    def self.year_days(years)
      years * ANNUAL_DAYS + self.leap_days(years)
    end

    # perform lookup by month number and year, one-indexed, with leap days
    def self.month_days(month, year)
      raise(InvalidMonth, month.inspect) unless (1..12).cover?(month)
      (month == 2 and self.leap_year?(year)) ?
        MON29 : MONTH_DAYS.fetch(month - 1)
    end

    # select the table based on leap year status
    def self.cumulative_table(year)
      self.leap_year?(year) ? CUMULATIVE_LEAP_DAYS : CUMULATIVE_DAYS
    end

    # fetch from the appropriate table, one-indexed
    def self.cumulative_days(month, year:)
      self.cumulative_table(year).fetch(month - 1)
    end
    
    # given number of days, what is the current month and day
    def self.month_and_day(day_of_year, year:)
      tbl = self.cumulative_table(year)
      idx = tbl.rindex { |c| c < day_of_year }
      [idx + 1, day_of_year - tbl[idx]]
    end
    
    #
    # Ordinal Coversions (days since Epoch, 0001-01-01)
    #

    # convert date (as year, month, day) to days since epoch
    def self.to_ordinal(year, month, day)
      raise(InvalidMonth, month.inspect) unless (1..12).cover?(month)
      self.year_days(year - 1) + self.cumulative_days(month, year:) + day
    end

    # convert days since epoch back to Date
    def self.from_ordinal(day_count)
      year, month, day = Date.to_ymd_flt(day_count)
      Date.new(year:, month:, day:, ordinal_day: day_count)
    end

    # use floating point and heuristic, very efficient
    def self.to_ymd_flt(day_count)
      raise(NegativeError, day_count.to_s) unless day_count > 0

      # this is a simple linear approximation; a guess
      year = ((day_count - 1) / MEAN_ANNUAL_DAYS).round + 1
      year_days = self.year_days(year - 1)

      # rewind the guess as needed, typically 0 or 1x, rarely 2x
      while year > MIN_Y and year_days >= day_count
        year -= 1
        year_days -= self.leap_year?(year) ? LEAP_YEAR_DAYS : ANNUAL_DAYS
      end

      month, day = self.month_and_day(day_count - year_days, year:)
      [year, month, day]
    end

    # use pure divmod arithmetic and integers; constant time; ~same~ efficiency
    def self.to_ymd_int(day_count)
      raise(NegativeError, day_count.to_s) unless day_count > 0

      # Convert to 0-based day count for easier math
      days = day_count - 1

      # 400 year cycle
      n400, days = days.divmod(DAYS_400)

      # 100-year cycle
      n100 = days / DAYS_100
      n100 = 3 if n100 == 4
      days -= (n100 * DAYS_100)

      # 4-year cycle
      n4, days = days.divmod(DAYS_4)

      # remaining years
      n1 = days / ANNUAL_DAYS
      n1 = 3 if n1 == 4

      # remaining days
      days -= (n1 * ANNUAL_DAYS)

      # determine the year
      year = 1 + (n400 * 400) + (n100 * 100) + (n4 * 4) + n1

      # add 1 back to 1-based day_count to determine the month and day
      month, day = self.month_and_day(days + 1, year:)
      [year, month, day]
    end

    #
    # Month Names
    #

    # define lookup of month name by month number, zero-indexed
    MONTH_NAMES = %w[January February March April May June
                     July August September October November December].freeze

    # define lookup by month name, symbols for keys, one-indexed values
    MONTH_NUMS = MONTH_NAMES.each.with_index.to_h { |name, i|
      [name.downcase.to_sym, i + 1]
    }.freeze

    # perform lookup by month name, one-indexed
    def self.month_number(name)
      name = name.downcase.to_sym if name.is_a? String
      MONTH_NUMS.fetch name
    end

    # perform lookup of month name by month number, one-indexed
    def self.month_name(number)
      raise(InvalidMonth, number.inspect) unless (1..12).cover?(number)
      MONTH_NAMES.fetch(number - 1)
    end

    #
    # Date Instances
    #

    # day count since epoch
    attr_reader :ordinal_day

    # ordinal_day will be calculated if not passed in
    def initialize(year:, month:, day:, ordinal_day: nil)
      # validate year
      raise(InvalidYear, year) unless (MIN_Y..MAX_Y).cover?(year)

      # handle month conversion
      case month
      when Integer
        raise(InvalidMonth, month) unless (MIN_M..MAX_M).cover?(month)
      else
        begin
          month = Date.month_number(month)
        rescue
          raise InvalidMonth, month.inspect
        end
      end

      # validate day
      max_days = Date.month_days(month, year)
      raise(InvalidDay, day) unless (MIN_D..max_days).cover?(day)

      # initialize
      @ordinal_day = ordinal_day || Date.to_ordinal(year, month, day)
      super(year:, month:, day:)
    end

    # YYYY-MM-DD, per ISO 8601
    def to_s
      format('%04d-%02d-%02d', year, month, day)
    end

    # given a Date, return a count of days, possibly negative
    def diff(other)
      @ordinal_day - other.ordinal_day
    end

    # per Comparable, return (-1, 0, +1) (less than, equals, greater than)
    def <=>(other)
      @ordinal_day <=> other.ordinal_day
    end

    # given a count of days, return a new Date
    def +(days)
      return self if days.zero?
      Date.from_ordinal(@ordinal_day + days)
    end

    # "February 29, 2004"
    def name
      format("%s %d, %d", Date.month_name(month), day, year)
    end

    # convenience
    def -(days)
      self.+(-1 * days)
    end

    # convenience
    def leap_year?
      Date.leap_year?(year)
    end
  end
end
