require 'stackprof'
require 'compsci/date'

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
start_year = 1500
end_year = 5000

# 100k non-august dates
99_999.times {
  year = rand(start_year..end_year)
  month, day = notable.to_a.sample
  month = CompSci::Date.month_number(month)
  dates << [year, month, day]
}

# 10k august dates
9_999.times {
  year = rand(start_year..end_year)
  dates << [year, 8, rand(1..31)]
}

dumpfile = 'stackprof-cpu.dump'

StackProf.run(mode: :wall, out: dumpfile, raw: true) {
  dates.each { |d|
    date = CompSci::Date.new(*d)
    other = CompSci::Date.new(*dates.sample)
    
    date + rand(9999)
    date - rand(9999)
    date.diff(other)
    date <=> other
  }
}

puts "generated #{dumpfile}"
puts "To generate flamegraph.html:"
puts
puts "stackprof #{dumpfile} --d3-flamegraph > flamegraph.html"
puts
