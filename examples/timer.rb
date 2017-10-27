require 'compsci/timer'

include CompSci

overall_start = Timer.now

start = Timer.now
print "running sleep 0.01 (50x): "
_answer, each_et = Timer.loop_avg(count: 50) {
  print '.'
  sleep 0.01
}
puts
puts "each: %0.3f" % each_et
puts "elapsed: %0.3f" % Timer.since(start)
puts "cumulative: %0.3f" % Timer.since(overall_start)
puts


start = Timer.now
print "running sleep 0.02 (0.3 s): "
_answer, each_et = Timer.loop_avg(seconds: 0.3) {
  print '.'
  sleep 0.02
}
puts
puts "each: %0.3f" % each_et
puts "elapsed: %0.3f" % Timer.since(start)
puts "cumulative: %0.3f" % Timer.since(overall_start)
puts
