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
