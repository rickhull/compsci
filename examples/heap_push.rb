require 'compsci/heap'
require 'compsci/timer'

include CompSci

runtime = (ARGV.shift || "3").to_i

puts <<EOF

#
# #{runtime} seconds worth of Heap pushes
#

EOF


# pregenerate a sequence of random numbers
# every NUMBERWANGth request, shift the sequence and push a new random
# this should mitigate random number generation from interfering with timing
# while also mitigating any chance of cyclic behavior
RANDMAX = 1_000
NUMBERWANG = 1_000
NUMS = (0..(RANDMAX - 1)).to_a.shuffle

def number(num)
  if num % NUMBERWANG == 0
    NUMS.shift
    NUMS.push rand RANDMAX
  end
  NUMS[num % RANDMAX]
end

count = 0
start = Timer.now
start_100k = Timer.now
h = Heap.new

loop {
  count += 1

  if count % 10000 == 0
    _answer, push_elapsed = Timer.elapsed { h.push number(count) }
    puts "%ith push: %0.8f s" % [count, push_elapsed]
    if count % 100000 == 0
      h.push number(count)
      push_100k_elapsed = Timer.since start_100k
      puts "-------------"
      puts "    100k push: %0.8f s (%ik push / s)" %
           [push_100k_elapsed, 100.to_f / push_100k_elapsed]
      puts
      start_100k = Timer.now
    end
  else
    h.push number(count)
  end

  break if Timer.since(start) > runtime
}

puts "pushed %i items in %0.1f s" % [count, Timer.since(start)]
puts

print "still a heap with #{h.size} items? "
answer, elapsed = Timer.elapsed { h.heap? }
puts "%s - %0.3f sec" % [answer ? 'YES' : 'NO', elapsed]
puts
