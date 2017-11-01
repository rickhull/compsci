require 'compsci/heap'
require 'compsci/timer'

include CompSci

puts <<EOF
#
# 3 seconds worth of pushes
#

EOF

count = 0
start = Timer.now
start_100k = Timer.now
h = Heap.new

loop {
  count += 1

  if count % 10000 == 0
    _answer, push_elapsed = Timer.elapsed { h.push rand 99999 }
    puts "%ith push: %0.8f s" % [count, push_elapsed]
    if count % 100000 == 0
      h.push rand 99999
      push_100k_elapsed = Timer.since start_100k
      puts "-------------"
      puts "    100k push: %0.8f s (%ik push / s)" %
           [push_100k_elapsed, 100.to_f / push_100k_elapsed]
      puts
      start_100k = Timer.now
    end
  else
    h.push rand 99999
  end

  break if Timer.since(start) > 3
}

puts "pushed %i items in %0.1f s" % [count, Timer.since(start)]
puts

print "still a heap with #{h.size} items? "
answer, elapsed = Timer.elapsed { h.heap? }
puts "%s - %0.3f sec" % [answer ? 'YES' : 'NO', elapsed]
puts
