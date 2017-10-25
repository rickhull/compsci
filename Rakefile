require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.pattern = "test/*.rb"
  t.warning = true
end

Rake::TestTask.new bench: :test do |t|
  t.pattern = "test/bench/*.rb"
  t.warning = true
  t.description = "Run benchmarks"
end

desc "Run example scripts"
task examples: :test do
  Dir['examples/**/*.rb'].each { |filepath|
    puts
    sh "ruby -Ilib #{filepath}"
    puts
  }
end

task default: :examples
