require 'compsci/fibonacci'
require 'minitest/autorun'

include CompSci

# CLASSIC_RANGE = [3, 5, 10, 15, 20, 25, 30, 31, 32, 33, 34, 35]
CLASSIC_RANGE = [10, 15, 20, 25, 30, 31, 32, 33, 34, 35]
# RECURSIVE_RANGE = [10, 100, 1000, 2500, 5000, 7500]
RECURSIVE_RANGE = [100, 1000, 2500, 5000, 7500]
# CACHE_RANGE = [100, 1000, 10000, 100000, 112500, 125000]
CACHE_RANGE = [100, 1000, 10000, 100000]

# this causes churn at the process level and impacts other benchmarks
# DYNAMIC_RANGE = [100, 1000, 10000, 100000, 200000, 500000]
DYNAMIC_RANGE = [100, 1000, 10000, 100000]
MATRIX_RANGE = [100, 1000, 10000, 100000]

#CLASS_BENCHMARK = true
BENCHMARK_IPS = true
CLASS_BENCHMARK = false
#BENCHMARK_IPS = false

if CLASS_BENCHMARK
  require 'compsci/timer'

  class BenchFib < Minitest::Benchmark
    def bench_fib
      times = CLASSIC_RANGE.map { |n|
        _answer, elapsed = Timer.elapsed { Fibonacci.classic(n) }
        elapsed
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

  # recursive benchmarks with low N; iterative for comparison
  Benchmark.ips do |b|
    b.config time: 3, warmup: 0.5
    num = 25

    b.report("Fibonacci.classic(#{num})") {
      Fibonacci.classic(num)
    }

    b.report("Fibonacci.cache_recursive(#{num})") {
      Fibonacci.cache_recursive(num)
    }

    b.report("Fibonacci.cache_iterative(#{num})") {
      Fibonacci.cache_iterative(num)
    }

    b.compare!
  end

  # nonrecursive benchmarks with high N
  Benchmark.ips do |b|
    b.config time: 3, warmup: 0.5
    num = 500

    b.report("Fibonacci.cache_iterative(#{num})") {
      Fibonacci.cache_iterative(num)
    }

    b.report("Fibonacci.dynamic(#{num})") {
      Fibonacci.dynamic(num)
    }

    b.report("Fibonacci.matrix(#{num})") {
      Fibonacci.matrix(num)
    }

    b.compare!
  end
end
