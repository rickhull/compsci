module CompSci
  class Timer
    SECS_PER_MIN = 60
    MINS_PER_HOUR = 60
    SECS_PER_HOUR = SECS_PER_MIN * MINS_PER_HOUR

    # returns a float representing seconds since epoch
    if defined? Process::CLOCK_MONOTONIC
      def self.now
        Process.clock_gettime Process::CLOCK_MONOTONIC
      end
    else
      def self.now
        Time.now.to_f
      end
    end

    def self.since f
      self.now - f
    end

    def self.elapsed &work
      f = self.now
      return yield, self.since(f)
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
      return val, self.since(start) / i
    end

    # HH::MM::SS.mmm.uuuuuuuu
    def self.elapsed_display(elapsed_ms, show_micro: false)
      elapsed_s, ms = elapsed_ms.divmod 1000
      ms_only, ms_fraction = ms.round(8).divmod 1

      h = elapsed_s / SECS_PER_HOUR
      elapsed_s -= h * SECS_PER_HOUR
      m, s = elapsed_s.divmod SECS_PER_MIN

      hmsms = [[h, m, s].map { |i| i.to_s.rjust(2, '0') }.join(':'),
               ms_only.to_s.rjust(3, '0')]
      hmsms << (ms_fraction * 10 ** 8).round.to_s.ljust(8, '0') if show_micro
      hmsms.join('.')
    end

    # YYYY-MM-DD HH::MM::SS.mmm
    def self.timestamp(t = Time.now)
      t.strftime "%Y-%m-%d %H:%M:%S.%L"
    end

    def restart(f = Timer.now)
      @start = f
      self
    end
    alias_method :initialize, :restart

    def elapsed(f = Timer.now)
      f - @start
    end

    def elapsed_ms(f = Timer.now)
      elapsed(f) * 1000
    end

    def elapsed_display(f = Timer.now)
      Timer.elapsed_display(elapsed_ms(f))
    end
    alias_method :to_s, :elapsed_display
    alias_method :inspect, :elapsed_display
  end
end
