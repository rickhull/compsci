require 'compsci/complete_tree'
require 'compsci/timer'
require 'compsci/fit'

include CompSci

timing = {}

[10, 100, 1000, 10_000, 100_000].each { |n|
  h = CompleteBinaryTree.new
  _val, secs = Timer.loop_avg {
    n.times { h.push rand }
  }
  puts "%ix push: %0.6f" % [n, secs]
  timing[n] = secs
  break if secs > 1
}

a, b, r2, fn = Fit.best timing.keys, timing.values

puts "best fit: #{fn} (%0.3f); a = %0.6f, b = %0.6f" % [r2, a, b]
