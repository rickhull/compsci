require 'compsci/heap'
require 'compsci/timer'

include CompSci

#
# 3 seconds worth of inserts
#

count = 0
start = Timer.now
h = Heap.new
elapsed = 0

while elapsed < 3
  push_elapsed = Timer.elapsed { h.push rand 99999 }
  count += 1
  puts "%ith push: %0.8f s" % [count, push_elapsed] if count % 10000 == 0

  if count % 100000 == 0
    start_100k ||= start
    push_100k_elapsed = Timer.now - start_100k
    puts "-------------"
    puts "    100k push: %0.8f s (%ik push / s)" %
         [push_100k_elapsed, 100.to_f / push_100k_elapsed]
    puts
    start_100k = Timer.now
  end
  elapsed = Timer.now - start
end

puts "pushed %i items in %0.1f s" % [count, elapsed]
puts

print "still a heap with #{h.size} items? "
answer = nil
elapsed = Timer.elapsed { answer = h.heap? }
puts "%s - %0.3f sec" % [answer ? 'YES' : 'NO', elapsed]
puts

#
# 99 inserts; display the internal array
#

h = Heap.new
print "push: ["
99.times {
  item = rand 99
  h.push item
  print "%i, " % item
}
puts "]"
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts

puts "pop: %i" % h.pop
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts

print "pop: ["
9.times {
  print "%i, " % h.pop
}
puts "]"
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts
