require 'compsci/simplex'

include CompSci

BENCH_IPS = true
BENCH_OBJECT_SPACE = true

SIMPLEX_PARAMS = [
  # 1 (index 0)
  [[1, 1],
   [[2,  1],
    [1,  2]],
   [4, 3]],

  [[3, 4],
   [[1, 1],
    [2, 1]],
   [4, 5]],

  [[2, -1],
   [[1, 2],
    [3, 2],],
   [6, 12]],

  [[60, 90, 300],
   [[1, 1, 1],
    [1, 3, 0],
    [2, 0, 1]],
   [600, 600, 900]],

  # 5
  [[70, 210, 140],
   [[1, 1, 1],
    [5, 4, 4],
    [40, 20, 30]],
   [100, 480, 3200]],

  [[2, -1, 2],
   [[2, 1, 0],
    [1, 2, -2],
    [0, 1, 2]],
   [10, 20, 5]],

  [[11, 16, 15],
   [[1, 2, Rational(3, 2)],
    [Rational(2, 3), Rational(2, 3), 1],
    [Rational(1, 2), Rational(1, 3), Rational(1, 2)]],
   [12_000, 4_600, 2_400]],

  [[5, 4, 3],
   [[2, 3, 1],
    [4, 1, 2],
    [3, 4, 2]],
   [5, 11, 8]],

  [[3, 2, -4],
   [[1, 4, 0],
    [2, 4,-2],
    [1, 1,-2]],
   [5, 6, 2]],

  # 10
  [[2, -1, 8],
   [[2, -4, 6],
    [-1, 3, 4],
    [0, 0, 2]],
   [3, 2, 1]],

  [[100_000, 40_000, 18_000],
   [[20, 6, 3],
    [0, 1, 0],
    [-1,-1, 1],
    [-9, 1, 1]],
   [182, 10, 0, 0]],

  [[1, 2, 1, 2],
   [[1, 0, 1, 0],
    [0, 1, 0, 1],
    [1, 1, 0, 0],
    [0, 0, 1, 1]],
   [1, 4, 2, 2]],

  [[10, -57, -9, -24],
   [[0.5, -5.5, -2.5, 9],
    [0.5, -1.5, -0.5, 1],
    [ 1,    0,    0, 0]],
   [0, 0, 1]],

  # 14 (index 13)
  [[25, 20],
   [[20, 12],
    [1, 1]],
   [1800, 8*15]],
]

def new_simplices
  SIMPLEX_PARAMS.map { |c, a, b| Simplex.new(c, a, b) }
end

if BENCH_IPS
  require 'benchmark/ips'

  Benchmark.ips do |b|
    b.config time: 3, warmup: 0.5

    b.report("Simplex init") {
      new_simplices
    }

    b.report("init, solve") {
      new_simplices.each { |s| s.solution }
    }

    #b.report("Simplex Matrix") {
    #}

    b.compare!
  end
end

if BENCH_OBJECT_SPACE
  require 'compsci/timer'
  require 'objspace'

  def disp_memsize(var, label = '')
    "memsize(%s): %i" % [label, ObjectSpace.memsize_of(var)]
  end

  simplices = SIMPLEX_PARAMS.map { |c, a, b|
    Simplex.new(c, a, b)
  }

  puts "SIMPLEX_PARAMS.size = #{SIMPLEX_PARAMS.size}"
  puts "simplices.size = #{simplices.size}"

  puts disp_memsize SIMPLEX_PARAMS, 'SIMPLEX_PARAMS'
  puts disp_memsize simplices, 'simplices'
  results = simplices.map { |s| s.solution }
  puts disp_memsize simplices, 'simplices after solving'
  puts disp_memsize results, 'results'
end
