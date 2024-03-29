Gem::Specification.new do |s|
  s.name = 'compsci'
  s.summary = "Toy implementations for some basic computer science problems"
  s.description = "Trees, Heaps, Timers, Error fitting, etc"
  s.authors = ["Rick Hull"]
  s.homepage = "https://github.com/rickhull/compsci"
  s.license = "LGPL-3.0"

  s.required_ruby_version = "~> 3.0"

  s.version = File.read(File.join(__dir__, 'VERSION')).chomp

  s.files = %w[compsci.gemspec VERSION README.md Rakefile]
  s.files += Dir['lib/**/*.rb']
  s.files += Dir['test/**/*.rb']
  s.files += Dir['examples/**/*.rb']

  s.add_dependency "matrix", "~> 0.4"
end
