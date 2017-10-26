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

  def self.elapsed &work
    t = self.now
    yield
    self.now - t
  end

  def self.loop_average(count: 999, seconds: 1, &work)
    i = 0
    t = self.now
    loop {
      yield
      i += 1
      break if i >= count
      break if self.now - t > seconds
    }
    (self.now - t) / i.to_f
  end
end
