require 'compsci/fibonacci'
require 'benchmark/ips'

include CompSci

# recursive benchmarks with low N
[10, 20, 30].each { |num|
  Benchmark.ips do |b|
    b.config time: 0.5, warmup: 0.05

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

    b.report("Fibonacci.matrix(#{num})") {
      Fibonacci.matrix(num)
    }

    b.compare!
  end
}

# nonrecursive benchmarks with high N
[50, 100, 150, 200, 500, 1000, 2000, 5000].each { |num|
  Benchmark.ips do |b|
    b.config time: 0.5, warmup: 0.05

    b.report("Fibonacci.cache_recursive(#{num})") {
      Fibonacci.cache_recursive(num)
    }

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
}
