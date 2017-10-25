require 'compsci/heap'

include CompSci

#
# 3 seconds worth of inserts
#

count = 0
t = Time.now
t2 = Time.now
h = Heap.new
elapsed = 0

while elapsed < 3
  t1 = Time.now
  h.push rand 99999
  e1 = Time.now - t1
  elapsed = Time.now - t
  count += 1
  puts "%ith push: %0.8f s" % [count, e1] if count % 10000 == 0

  if count % 100000 == 0
    e2 = Time.now - t2
    t2 = Time.now
    puts "-------------"
    puts "    100k push: %0.8f s (%ik push / s)" % [e2, 100.to_f / e2]
    puts
  end
end

puts "pushed %i items in %0.1f s" % [count, elapsed]
puts

print "still a heap with #{h.size} items? "
t = Time.now
if h.heap?
  puts "YES - %0.2f sec" % (Time.now - t)
else
  puts "NO - %0.4f sec" % (Time.now - t)
end
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
