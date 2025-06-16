require 'benchmark/ips'
require 'compsci/date'

day_counts = []

# Early years (where the leap day pattern hasn't fully established)
(1..100).each { |d| day_counts << d }
(360..400).each { |d| day_counts << d } # Around year 2
(1460..1470).each { |d| day_counts << d } # Around the first 4-year cycle

# Years far in the future (where the error of the linear approx accumulates)
# Day counts for years 8000-9999
(2_922_000..3_652_000).step(1000).each { |d| day_counts << d }

# quick cross-check
day_counts.each { |d|
  f = CompSci::Date.to_ymd_flt(d)
  i = CompSci::Date.to_ymd_int(d)

  if f != i
    raise format("flt != int: (%s, %s)", f.join('-'), i.join('-'))
  end
}

puts "--- Benchmarking from_ordinal on Edge Case Dates ---"
Benchmark.ips { |b|
  b.config(warmup: 0.5, time: 2)

  b.report("to_ymd_flt") {
    CompSci::Date.to_ymd_flt(day_counts.sample)
  }

  b.report("to_ymd_int") {
    CompSci::Date.to_ymd_int(day_counts.sample)
  }

  b.compare!
}
