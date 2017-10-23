require 'compsci/heap'

include CompSci

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
  puts "%ith insert: %0.8f s" % [count, e1] if count % 10000 == 0
end

puts "inserted %i items in %0.1f s" % [count, elapsed]
