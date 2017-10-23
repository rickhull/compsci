require 'compsci/fib'
require 'minitest/autorun'
require 'minitest/benchmark'

include CompSci

# CLASSIC_RANGE = [3, 5, 10, 15, 20, 25, 30, 31, 32, 33, 34, 35]
CLASSIC_RANGE = [10, 15, 20, 25, 30, 31, 32, 33, 34, 35]

SPEC_BENCHMARK = true
CLASS_BENCHMARK = true
BENCHMARK_IPS = true


if SPEC_BENCHMARK
  describe "Benchmark" do
    bench_range do
      CLASSIC_RANGE
    end

    fc = ["Fibonacci.classic (exponential, 0.95)", 0.95]
    bench_performance_exponential(*fc) do |n|
      Fibonacci.classic(n)
    end

    fcr = ["Fibonacci.cache_recursive (linear, 0.95)", 0.95]
    bench_performance_linear(*fcr) do |n|
      Fibonacci.cache_recursive(n)
    end
  end
end

if CLASS_BENCHMARK
  class BenchFib < Minitest::Benchmark
    def bench_fib
      times = CLASSIC_RANGE.map { |n|
        t = Time.now
        Fibonacci.classic(n)
        Time.now - t
      }
      _a, _b, r2 = self.fit_exponential(CLASSIC_RANGE, times)
      puts
      puts "self-timed Fibonacci.classic(n) exponential fit: %0.3f" % r2
      puts
    end
  end
end

if BENCHMARK_IPS
  require 'benchmark/ips'

  Benchmark.ips do |b|
    b.config time: 3, warmup: 0.5
    num = 25

    b.report("classic(#{num})") {
      Fibonacci.classic(num)
    }

    b.report("cache_recursive(#{num})") {
      Fibonacci.cache_recursive(num)
    }

    b.report("cache_iterative(#{num})") {
      Fibonacci.cache_iterative(num)
    }

    b.report("dynamic(#{num})") {
      Fibonacci.dynamic(num)
    }

    b.compare!
  end
end
