# This library implements a proleptic Gregorian calendar:
# * The Julian-Gregorian transition in 1582 is ignored
# * The Gregorian calendar extends backwards to year 1
# * The epoch is 0001-01-01

module CompSci
  class Date < Data.define(:year, :month, :day)
    class InvalidYear < RuntimeError; end
    class InvalidMonth < RuntimeError; end
    class InvalidDay < RuntimeError; end

    include Comparable

    # this is the crux of the Gregorian calendar
    def self.leap_year?(year)
      (year % 4).zero? and !(year % 100).zero? or (year % 400).zero?
    end

    # cumulative leap days from year 1 up to and including _year_
    # This counts leap days in years 1, 2, 3, ..., year
    def self.leap_days(year)
      return 0 if year <= 3
      (year / 4) - (year / 100) + (year / 400)
    end

    # furthermore:
    ANNUAL_DAYS = 365
    LEAP_YEAR_DAYS = 366
    
    # perform lookup annual days by year
    def self.annual_days(year)
      self.leap_year?(year) ? LEAP_YEAR_DAYS : ANNUAL_DAYS
    end
    
    # define lookup of month name by month number, zero-indexed
    MONTH_NAMES = %w[January February March April May June
                     July August September October November December].freeze

    # perform lookup of month name by month number, one-indexed
    def self.month_name(number)
      MONTH_NAMES.fetch(number - 1)
    end

    # define lookup by month name, symbols for keys, one-indexed values
    MONTH_NUMS = MONTH_NAMES.each.with_index.to_h { |name, i|
      [name.downcase.to_sym, i + 1]
    }.freeze
    
    # perform lookup by month name, one-indexed
    def self.month_number(name)
      name = name.downcase.to_sym if name.is_a? String
      MONTH_NUMS.fetch name
    end
    
    # define lookup by month number, zero-indexed
    MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze
    
    # perform lookup by month number and year, one-indexed, with leap days
    def self.month_days(month, year)
      (month == 2 and self.leap_year?(year)) ? 29 : MONTH_DAYS.fetch(month - 1)
    end
    
    # define lookup by month number, zero-indexed
    CUMULATIVE_DAYS =
      [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334].freeze
    
    # perform lookup by month number and year, one-indexed, with leap days
    def self.cumulative_days(month, year)
      days = CUMULATIVE_DAYS.fetch(month - 1)
      (month > 2 and self.leap_year?(year)) ? days + 1 : days
    end
    
    # convert date to days since epoch (year 1, month 1, day 1)
    def self.day_count(year, month, day)
      (year - 1) * ANNUAL_DAYS +
        self.leap_days(year - 1) +
        self.cumulative_days(month, year) +
        day
    end
    
    # convert days since epoch back to date
    def self.from_days(total_days)
      raise(RuntimeError, "total_days must be > 0") unless total_days > 0
      
      # overestimate year (will be close, may need reduction)
      year = ((total_days - 1) / ANNUAL_DAYS) + 1
      
      # given the estimate, how many days, actually?
      day_count = self.day_count(year, 1, 1)
      
      # reduce year if the estimate is too high
      while total_days < day_count
        year -= 1
        day_count -= self.annual_days(year)
      end
      
      # current year, how many days to account for?
      days_left = total_days - day_count + 1
      
      # sanity check
      unless (1..366).cover? days_left
        raise(RuntimeError, "days_left: #{days_left}")
      end
      
      # determine month and day
      1.upto(12).each { |month|
        days = self.month_days(month, year)
        return Date.new(year, month, days_left) if days_left <= days
        days_left -= days
      }
      
      # sanity check - should never reach here
      raise(RuntimeError, "days_left after 12 month loop: #{days_left}")
    end
    
    attr_reader :day_count
    
    def initialize(year:, month:, day:)
      # validate year
      raise(InvalidYear, year) unless (1..9999).cover?(year)
      
      # handle month conversion
      case month
      when Integer
        raise(InvalidMonth, month) unless (1..12).cover?(month)
      else
        begin
          month = Date.month_number(month)
        rescue
          raise InvalidMonth, month.inspect
        end
      end
      
      # validate day
      max_days = Date.month_days(month, year)
      raise(InvalidDay, day) unless (1..max_days).cover?(day)
      
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
      self.+(-days)
    end

    # given a Date, return a count of days, possibly negative
    def diff(other)
      @day_count - other.day_count
    end
  end
end
