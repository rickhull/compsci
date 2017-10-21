require 'compsci'

module CompSci::Timer
  def self.loop_average(count: 999, seconds: 1, &work)
    i = 0
    t = Time.now
    loop {
      yield
      i += 1
      break if i >= count
      break if Time.now - t > seconds
    }
    (Time.now - t) / i.to_f
  end
end

if __FILE__ == $0
  start = Time.now
  t = Time.now
  puts
  print "running: "
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
  print "running: "
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
  print "running: "
  block_time = Timer.loop_average(seconds: 1) {
    print '.'
    sleep 2
  }
  puts
  puts "each: %0.3f" % block_time
  puts "elapsed: %0.3f" % (Time.now - t)
  puts "cumulative: %0.3f" % (Time.now - start)
end
