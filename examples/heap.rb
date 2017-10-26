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
  _answer, push_elapsed = Timer.elapsed { h.push rand 99999 }
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
answer, elapsed = Timer.elapsed { h.heap? }
puts "%s - %0.3f sec" % [answer ? 'YES' : 'NO', elapsed]
puts

puts <<EOF
#
# 99 inserts; display the internal array
#

EOF

h = Heap.new

puts "push: %s" % Array.new(99) { rand(99).tap { |i| h.push i } }.join(' ')
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts

puts "pop: %i" % h.pop
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts

puts "pop: %s" % Array.new(9) { h.pop }.join(' ')
puts "heap store: #{h.store.inspect}"
puts "heap: #{h.heap?}"
puts
