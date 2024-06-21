require 'compsci/complete_tree'
require 'compsci/timer'
require 'compsci/fit'

include CompSci

timing = {}
ns = [10, 100, 1000, 10_000, 100_000]

# Note, CompleteTree is a very thin wrapper around Array, so we are just
# testing ruby's inherent Array performance here.
# Append / push / insert is constant for ruby Arrays.

puts <<EOF

#
# timing CompleteTree(N)#push where N is the size of the tree
#

EOF

ns.each { |n|
  h = CompleteTree.new
  n.times { h.push rand }
  _val, secs = Timer.loop_avg {
    h.push rand
  }
  puts "CompleteTree(%i) push: %0.8f" % [n, secs]
  timing[n] = secs
  break if secs > 1
}

a, b, r2, fn = Fit.best timing.keys, timing.values

puts "best fit: #{fn} (%0.3f); a = %0.6f, b = %0.6f" % [r2, a, b]



puts <<EOF

#
# timing CompleteTree#push where N is the count of pushes per batch
#

EOF

ns.each { |n|
  h = CompleteTree.new
  _val, secs = Timer.loop_avg {
    n.times { h.push rand }
  }
  puts "%ix CompleteTree#push: %0.8f" % [n, secs]
  timing[n] = secs
  break if secs > 1
}

a, b, r2, fn = Fit.best timing.keys, timing.values

puts "best fit: #{fn} (%0.3f); a = %0.6f, b = %0.6f" % [r2, a, b]
