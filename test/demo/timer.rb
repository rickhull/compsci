require 'compsci/timer'

include CompSci

start = Time.now
t = Time.now
puts
print "running sleep 0.01 (50x): "
block_time = Timer.loop_average(count: 50) {
  print '.'
  sleep 0.01
}
puts
puts "each: %0.3f" % block_time
puts "elapsed: %0.3f" % (Time.now - t)
puts "cumulative: %0.3f" % (Time.now - start)

t = Time.now
puts
print "running sleep 0.02 (0.5 s): "
block_time = Timer.loop_average(seconds: 0.5) {
  print '.'
  sleep 0.02
}
puts
puts "each: %0.3f" % block_time
puts "elapsed: %0.3f" % (Time.now - t)
puts "cumulative: %0.3f" % (Time.now - start)

t = Time.now
puts
print "running sleep 2 (1 s): "
block_time = Timer.loop_average(seconds: 1) {
  print '.'
  sleep 2
}
puts
puts "each: %0.3f" % block_time
puts "elapsed: %0.3f" % (Time.now - t)
puts "cumulative: %0.3f" % (Time.now - start)
