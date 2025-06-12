require 'benchmark/ips'
require 'compsci/date'
require 'date'

notable = {
  january: 1,    # new year's
  february: 14,  # valentine's
  march: 17,     # st patrick's
  april: 1,      # april fools
  may: 5,        # cinco dy mayo
  june: 19,      # juneteenth
  july: 4,       # 4th of july
  # august: no fixed dates
  september: 11, # sep 11 2001 WTC
  october: 31,   # halloween
  november: 11,  # veterans'
  december: 25,  # christmas
}

dates = []
start_year = 1583 # after the julian-gregorian transition
end_year = 3000

# 99 non-august dates
99.times {
  year = rand(start_year..end_year)
  month, day = notable.to_a.sample
  month = CompSci::Date.month_number(month)
  dates << [year, month, day]
}

# 9 august dates
9.times {
  year = rand(start_year..end_year)
  dates << [year, 8, rand(1..31)]
}

pairs = []

999.times {
  pairs << dates.sample(2)
}

Benchmark.ips { |b|
  b.config(warmup: 0.2, time: 1)

  b.report("Ruby Date Difference") {
    pairs.each { |(d1, d2)|
      rd1 = Date.new(*d1)
      rd2 = Date.new(*d2)
      rd1 - rd2
    }
  }

  b.report("CompSciDate Difference") {
    pairs.each { |(d1, d2)|
      cd1 = CompSci::Date.new(*d1)
      cd2 = CompSci::Date.new(*d2)
      cd2.diff(cd1)
    }
  }

  b.compare!
}

Benchmark.ips { |b|
  b.config(warmup: 0.2, time: 1)

  b.report("Ruby Date new") {
    rd = Date.new(*dates.sample)
    99.times {
      rd + rand(9999)
      rd - rand(9999)
    }
  }

  b.report("CompSci::Date new") {
    cd = CompSci::Date.new(*dates.sample)
    99.times {
      val = rand(9999)
      begin
        cd + val
        cd - val
      rescue => e
        puts format("Exception: %s: %s; %s +- %i", e.class, e.message, cd, val)
      end
    }
  }

  b.compare!
}
