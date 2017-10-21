require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.pattern = "test/*.rb"
  t.warning = true
end

Rake::TestTask.new(bench: :test) do |t|
  t.pattern = "test/bench/*.rb"
  t.warning = true
end

task default: :bench
