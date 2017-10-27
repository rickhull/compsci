require 'compsci'

module CompSci::Timer
  # lifted from seattlerb/minitest
  if defined? Process::CLOCK_MONOTONIC
    def self.now
      Process.clock_gettime Process::CLOCK_MONOTONIC
    end
  else
    def self.now
      Time.now
    end
  end

  def self.since(t)
    self.now - t
  end

  def self.elapsed(&work)
    t = self.now
    return yield, self.since(t)
  end

  def self.loop_avg(count: 999, seconds: 1, &work)
    i = 0
    start = self.now
    val = nil
    loop {
      val = yield
      i += 1
      break if i >= count
      break if self.since(start) > seconds
    }
    return val, self.since(start) / i.to_f
  end
end
