require 'compsci/heap'

include CompSci

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

print "pop: %i" % h.pop
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

#
# 3 seconds worth of inserts
#

count = 1
t = Time.now
h = Heap.new
elapsed = 0

while elapsed < 3
  t1 = Time.now
  h.push rand 99999
  e1 = Time.now - t1
  elapsed = Time.now - t
  count += 1
  puts "%ith push: %0.8f s" % [count, e1] if count % 10000 == 0
end

puts "pushed %i items in %0.1f s" % [count, elapsed]
