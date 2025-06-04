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

    include Comparable

    # 
    # Gregorian Calendar Leap Years
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
    # Gregorian Calendar Definitions
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
    NUM_MONTHS = 12 # MONTH_DAYS.size
    
    # derive CUMULATIVE_DAYS from MONTH_DAYS, zero-indexed
    CUMULATIVE_DAYS = MONTH_DAYS.reduce([0]) { |acc, days|
      acc + [acc.last + days]
    } # [0, 31, 59, 90, 120, ... 365]
    ANNUAL_DAYS = CUMULATIVE_DAYS.pop  # 365
    LEAP_YEAR_DAYS = ANNUAL_DAYS + 1   # 366
    CUMULATIVE_DAYS.freeze

    MEAN_ANNUAL_DAYS = 365.2425
    MEAN_MONTH_DAYS = MEAN_ANNUAL_DAYS / NUM_MONTHS
    
    # implementation considerations
    MIN_Y, MIN_M, MIN_D = 1, 1, 1
    MAX_Y, MAX_M, MAX_D = 9999, NUM_MONTHS, MON31
    EPOCH_Y, EPOCH_M, EPOCH_D = 1, 1, 1
    
    #
    # Gregorian Calendar Functions
    #
    
    # perform lookup by month number and year, one-indexed, with leap days
    def self.month_days(month, year)
      (month == 2 and self.leap_year?(year)) ?
        MON29 : MONTH_DAYS.fetch(month - 1)
    end
    
    # given a day count, what is the current month?
    # despite leap years, never guess too low, only too high
    def self.guess_month(days)
      (days / MON30 + 1).clamp(MIN_M, MAX_M)
    end
    
    # perform lookup by month number and year, one-indexed, with leap days
    def self.cumulative_days(month, year)
      days = CUMULATIVE_DAYS.fetch(month - 1)
      (month > 2 and self.leap_year?(year)) ? (days + 1) : days
    end

    # given number of days, what is the current month and day
    def self.rev_cumulative(days, year)
      month = self.guess_month(days)
      month_days = self.cumulative_days(month, year)

      # rewind the guess by one month if needed
      if month > 1 and month_days >= days
        month -= 1
        month_days = self.cumulative_days(month, year)
      end

      [month, days - month_days]
    end

    # given a day count, what is the current year?
    # despite leap years, never guess too low, only too high
    # mostly accurate, errs by 1 at most
    def self.guess_year(days)
      bias = 2 # minimum required to meet guarantees above
      ((days + bias) / ANNUAL_DAYS + 1).clamp(MIN_Y, MAX_Y)
    end

    # how many days in the years since epoch
    def self.year_days(years)
      years * ANNUAL_DAYS + self.leap_days(years)
    end
    
    # how many days in a given year?
    def self.annual_days(year)
      self.leap_year?(year) ? LEAP_YEAR_DAYS : ANNUAL_DAYS
    end
    
    # convert days to current year with days remaining
    def self.year_count(days)
      year = self.guess_year(days)
      year_days = self.year_days(year - 1)

      # rewind the guess as needed
      while year > 1 and year_days >= days
        year -= 1
        year_days -= self.annual_days(year)
      end

      [year, days - year_days]
    end

    #
    # Gregorian Calendar Coversions (days since Epoch, 0001-01-01)
    #

    # convert date (as year, month, day) to days since epoch
    def self.day_count(year, month, day)
      self.year_days(year - 1) +
        self.cumulative_days(month, year) +
        day
    end

    # convert days since epoch back to Date
    def self.from_days(days)
      raise(RuntimeError, "days should be positive: #{days}") unless days > 0
      year, days = self.year_count(days)
      month, day = self.rev_cumulative(days, year)
      Date.new(year, month, day)
    end
    
    #
    # Gregorian Month Names
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
      MONTH_NAMES.fetch(number - 1)
    end

    #
    # Gregorian Calendar Instances
    #
    
    attr_reader :day_count
    
    def initialize(year:, month:, day:)
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
      
      @leap_year = Date.leap_year?(year)
      @day_count = Date.day_count(year, month, day)
      
      super(year:, month:, day:)
    end
    
    def leap_year?
      @leap_year
    end

    def <=>(other)
      @day_count <=> other.day_count
    end

    def to_s
      format('%04d-%02d-%02d', year, month, day)
    end

    def name
      format("%s %d, %d", Date.month_name(month), day, year)
    end

    # given a count of days, return a new Date
    def +(days)
      return self if days.zero?
      Date.from_days(@day_count + days)
    end

    def -(days)
      self.+(-1 * days)
    end

    # given a Date, return a count of days, possibly negative
    def diff(other)
      @day_count - other.day_count
    end
  end
end
