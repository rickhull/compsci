require 'compsci/fib'
require 'minitest/autorun'
require 'minitest/benchmark'

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

SPEC_BENCHMARK = true
CLASS_BENCHMARK = true
BENCHMARK_IPS = true


if SPEC_BENCHMARK
  describe "Fibonacci.classic Benchmark" do
    bench_range do
      CLASSIC_RANGE
    end

    fc = ["Fibonacci.classic (exponential, 0.95)", 0.95]
    bench_performance_exponential(*fc) do |n|
      Fibonacci.classic(n)
    end
  end

  describe "Fibonacci.cache_recursive Benchmark" do
    bench_range do
      RECURSIVE_RANGE
    end

    fcr = ["Fibonacci.cache_recursive (linear, 0.95)", 0.95]
    bench_performance_linear(*fcr) do |n|
      Fibonacci.cache_recursive(n)
    end
  end

  describe "Fibonacci.cache_iterative Benchmark" do
    bench_range do
      CACHE_RANGE
    end

    fci = ["Fibonacci.cache_iterative (linear, 0.99)", 0.99]
    bench_performance_linear(*fci) do |n|
      Fibonacci.cache_iterative(n)
    end
  end

  describe "Fibonacci.dynamic Benchmark" do
    bench_range do
      DYNAMIC_RANGE
    end

    fd = ["Fibonacci.dynamic (linear, 0.99)", 0.99]
    bench_performance_linear(*fd) do |n|
      Fibonacci.dynamic(n)
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

    b.report("Fibonacci.classic(#{num})") {
      Fibonacci.classic(num)
    }

    b.report("Fibonacci.cache_recursive(#{num})") {
      Fibonacci.cache_recursive(num)
    }

    b.report("Fibonacci.cache_iterative(#{num})") {
      Fibonacci.cache_iterative(num)
    }

    b.report("Fibonacci.dynamic(#{num})") {
      Fibonacci.dynamic(num)
    }

    b.compare!
  end
end
