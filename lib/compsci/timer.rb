module CompSci
  class Timer
    SECS_PER_MIN = 60
    MINS_PER_HOUR = 60
    SECS_PER_HOUR = SECS_PER_MIN * MINS_PER_HOUR

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

    # YYYY-MM-DD HH::MM::SS.mmm
    def self.timestamp(t = Time.now)
      t.strftime "%Y-%m-%d %H:%M:%S.%L"
    end

    # HH::MM::SS.mmm.uuuuuuuu
    def self.elapsed_display(elapsed_ms, show_us: false)
      elapsed_s, ms = elapsed_ms.divmod 1000
      ms_only, ms_fraction = ms.round(8).divmod 1

      h = elapsed_s / SECS_PER_HOUR
      elapsed_s -= h * SECS_PER_HOUR
      m, s = elapsed_s.divmod SECS_PER_MIN

      hmsms = [[h, m, s].map { |i| i.to_s.rjust(2, '0') }.join(':'),
               ms_only.to_s.rjust(3, '0')]
      hmsms << (ms_fraction * 10 ** 8).round.to_s.ljust(8, '0') if show_us
      hmsms.join('.')
    end

    def restart(t = Timer.now)
      @start = t
      self
    end
    alias_method :initialize, :restart

    def timestamp(t = Time.now)
      self.class.timestamp t
    end

    def timestamp!(t = Time.now)
      puts '-' * 70, timestamp(t), '-' * 70
    end

    def elapsed(t = Timer.now)
      t - @start
    end

    def elapsed_ms(t = Timer.now)
      elapsed(t) * 1000
    end

    def elapsed_display(t = Timer.now)
      self.class.elapsed_display(elapsed_ms(t))
    end
    alias_method :to_s, :elapsed_display
    alias_method :inspect, :elapsed_display

    def stamp(msg = '', t = Timer.now)
      format("%s %s", elapsed_display(t), msg)
    end

    def stamp!(msg = '', t = Timer.now)
      puts stamp(msg, t)
    end
  end
end
