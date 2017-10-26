Gem::Specification.new do |s|
  s.name = 'compsci'
  s.summary = "Toy implementations for some basic computer science problems"
  s.description = "Trees, Heaps, Timers, Error fitting, etc"
  s.authors = ["Rick Hull"]
  s.homepage = "https://github.com/rickhull/compsci"
  s.license = "LGPL-3.0"

  s.required_ruby_version = "~> 2"

  s.version = File.read(File.join(__dir__, 'VERSION')).chomp

  s.files = %w[
    compsci.gemspec
    VERSION
    README.md
    Rakefile
    lib/compsci.rb
    lib/compsci/fib.rb
    lib/compsci/fit.rb
    lib/compsci/heap.rb
    lib/compsci/timer.rb
    lib/compsci/tree.rb
    examples/binary_tree.rb
    examples/heap.rb
    examples/timer.rb
    test/fib.rb
    test/fit.rb
    test/heap.rb
    test/timer.rb
    test/tree.rb
    test/bench/fib.rb
    test/bench/heap.rb
    test/bench/tree.rb
  ]

  s.add_development_dependency "minitest", "~> 5.0"
end
