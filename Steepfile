D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib/compsci/bit_set.rb"
  check "lib/compsci/bloom_filter.rb"
  check "lib/compsci/byte_pack.rb"
  check "lib/compsci/collatz.rb"
  check "lib/compsci/elo.rb"
  check "lib/compsci/fibonacci.rb"
  check "lib/compsci/fit.rb"
  check "lib/compsci/heap.rb"
  # ...
  check "lib/compsci/oracle.rb"
  # ...
  check "lib/compsci/util.rb"

  library "zlib"

  # not actually needed
  # library "forwardable"
  # library "matrix"

  configure_code_diagnostics(D::Ruby.strict)
end
