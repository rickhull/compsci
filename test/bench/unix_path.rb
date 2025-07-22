require 'benchmark/ips'
require 'compsci/unix_path'

include CompSci

AF = ('a'..'f')
AF_MU = AF.map { |s| MutablePath.parse(s) }
AF_IM = AF.map { |s| ImmutablePath.parse(s) }

# compare UnixPath / String to UnixPath / UnixPath
# compare MutablePath to ImmutablePath
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
    AF_IM.each { |p| path = path / p }
  end

  b.report("MutablePath / UnixPath") do
    path = MutablePath.new
    AF_MU.each { |p| path / p }
  end

  b.compare!
end

AZ = ('a'..'z')
AZ_MU = AZ.map { |s| MutablePath.parse(s) }
AZ_IM = AZ.map { |s| ImmutablePath.parse(s) }

# now just doing UnixPath / UnixPath but with more chained slashes
Benchmark.ips do |b|
  b.config(warmup: 0.2, time: 1)

  b.report("ImmutablePath a-z") do
    path = ImmutablePath.new
    AZ_IM.each { |p| path = path / p }
  end

  b.report("MutablePath a-z") do
    path = MutablePath.new
    AZ_MU.each { |p| path / p }
  end

  b.compare!
end
