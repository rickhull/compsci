autoload :Matrix, 'matrix'

module CompSci
  module Fibonacci
    def self.classic(n)
      n < 2 ? n : classic(n-1) + classic(n-2)
    end

    def self.cache_recursive(n, cache = {})
      return n if n < 2
      cache[n] ||= cache_recursive(n-1, cache) + cache_recursive(n-2, cache)
    end

    # linear space and time
    def self.cache_iterative(n)
      cache = [0, 1]
      2.upto(n) { |i| cache[i] = cache[i-1] + cache[i-2] }
      cache[n]
    end

    # constant space, linear time
    def self.dynamic(n)
      a, b = 0, 1
      n.times { a, b = b, a+b }
      a
    end

    # https://ianthehenry.com/posts/fibonacci/
    def self.matrix(n)
      (Matrix[[1, 1], [1, 0]] ** n.pred)[0, 0] # steep:ignore
    end
  end
end
