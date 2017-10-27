autoload :Matrix, 'matrix'

module CompSci
  class Fibonacci
    def self.classic(n)
      n < 2 ? n : classic(n-1) + classic(n-2)
    end

    def self.cache_recursive(n, cache = {})
      return n if n < 2
      cache[n] ||= cache_recursive(n-1, cache) + cache_recursive(n-2, cache)
    end

    def self.cache_iterative(n)
      cache = [0, 1]
      2.upto(n) { |i| cache[i] = cache[i-1] + cache[i-2] }
      cache[n]
    end

    # traditional
    def self.dynamic(n)
      a, b = 0, 1
      n.times { a, b = b, a+b }
      a
    end

    # fails for n == 0
    def self.dynamic_fast(n)
      a, b = 0, 1
      (n-1).times { a, b = b, a+b }
      b
    end

    # https://gist.github.com/havenwood/02cf291b809327d96a3f
    # slower than dynamic until around n == 500
    def self.matrix(n)
      (Matrix[[0, 1], [1, 1]] ** n.pred)[1, 1].to_i
    end
  end
end
