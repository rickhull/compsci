require 'compsci/fibonacci'
require 'benchmark/ips'

include CompSci

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
