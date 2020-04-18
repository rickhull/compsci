Gem::Specification.new do |s|
  s.name = 'compsci'
  s.summary = "Toy implementations for some basic computer science problems"
  s.description = "Trees, Heaps, Timers, Error fitting, etc"
  s.authors = ["Rick Hull"]
  s.homepage = "https://github.com/rickhull/compsci"
  s.license = "LGPL-3.0"

  s.required_ruby_version = "~> 2"

  s.version = File.read(File.join(__dir__, 'VERSION')).chomp

  s.files = %w[compsci.gemspec VERSION README.md Rakefile]
  s.files += Dir['lib/**/*.rb']
  s.files += Dir['test/**/*.rb']
  s.files += Dir['examples/**/*.rb']

  s.add_development_dependency "buildar", "~> 3.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "> 12.3.3"
  s.add_development_dependency "flog", "~> 0"
  s.add_development_dependency "flay", "~> 0"
  s.add_development_dependency "roodi", "~> 0"
  s.add_development_dependency "ruby-prof", "~> 0"
  s.add_development_dependency "benchmark-ips", "~> 2.0"
end
