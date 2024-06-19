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

  # library "pathname"              # Standard libraries
  # library "strong_json"           # Gems

  library "zlib"
  # library "matrix"

  configure_code_diagnostics(D::Ruby.strict)
end
