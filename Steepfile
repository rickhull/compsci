D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib/compsci/elo.rb"
  check "lib/compsci/string_pack.rb"
  # check "lib/compsci/byte_pack.rb"   # 14 inconsequential errors
  # check "lib/compsci/bit_set.rb"     #  2 inconsequential errors
  check "lib/compsci/bloom_filter.rb"

  # library "pathname"              # Standard libraries
  # library "strong_json"           # Gems

  library "zlib"

  # configure_code_diagnostics(D::Ruby.strict)
end
