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


# --- Benchmark 1: Object Creation ---
puts "--- Benchmarking Object Creation (new) ---"
d = dates.sample

Benchmark.ips { |b|
  b.config(warmup: 0.2, time: 1)
  b.report("Ruby Date new") { Date.new(*d) }
  b.report("CompSci::Date new") { CompSci::Date.new(*d) }
  b.compare!
}

# --- Benchmark 2: Date Arithmetic (+, -) ---
# Create objects outside the loop so we only measure the arithmetic
puts "\n--- Benchmarking Date Arithmetic (+, -) ---"
rdate = Date.new(2024, 1, 1)
cdate = CompSci::Date.new(year: 2024, month: 1, day: 1)
days = rand(9999)

Benchmark.ips { |b|
  b.config(warmup: 0.2, time: 1)
  b.report("Ruby Date +/-") {
    rdate + days
    rdate - days
  }
  b.report("CompSci::Date +/-") {
    cdate + days
    cdate - days
  }
  b.compare!
}

# --- Benchmark 3: Date Difference ---
# Create objects outside the loop so we only measure the difference
puts "\n--- Benchmarking Date Difference ---"
d1, d2 = dates.sample(2)
r1 = Date.new(*d1)
r2 = Date.new(*d2)
c1 = CompSci::Date.new(*d1)
c2 = CompSci::Date.new(*d2)

Benchmark.ips { |b|
  b.config(warmup: 0.2, time: 1)
  b.report("Ruby Date diff") { r1 - r2 }
  b.report("CompSci::Date diff") { c1.diff(c2) }
  b.compare!
}
