require 'benchmark/ips'
require 'compsci/unix_path'

include CompSci

AF = %w[a b c d e f]
AF_MU = AF.map { |s| MutablePath.parse(s) }
AF_IMMU = AF.map { |s| ImmutablePath.parse(s) }

Benchmark.ips do |b|
  b.config(warmup: 0.2, time: 1)

  b.report("ImmutablePath / String") do
    ImmutablePath.new / 'a' / 'b' / 'c' / 'd' / 'e' / 'f'
  end

  b.report("MutablePath / String") do
    MutablePath.new / 'a' / 'b' / 'c' / 'd' / 'e' / 'f'
  end

  b.report("ImmutablePath / UnixPath") do
    path = ImmutablePath.new
    AF_IMMU.each { |p| path = path / p }
  end

  b.report("MutablePath / UnixPath") do
    path = MutablePath.new
    AF_MU.each { |p| path / p }
  end

  b.compare!
end
