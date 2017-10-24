require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.pattern = "test/*.rb"
  t.warning = true
end

Rake::TestTask.new(bench: :test) do |t|
  t.pattern = "test/bench/*.rb"
  t.warning = true
  t.description = "Run benchmarks"
end

Rake::TestTask.new(demo: :test) do |t|
  t.pattern = "test/demo/*.rb"
  t.warning = true
  t.description = "Run demos"
end

task default: :test