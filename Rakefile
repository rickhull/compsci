require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.pattern = "test/*.rb"
  t.warning = true
end

Rake::TestTask.new bench: [:test, :loadavg] do |t|
  t.pattern = "test/bench/*.rb"
  t.warning = true
  t.description = "Run benchmarks"
end

desc "Run example scripts"
task examples: [:test, :loadavg] do
  Dir['examples/**/*.rb'].each { |filepath|
    puts
    sh "ruby -Ilib #{filepath}"
    puts
  }
end

task default: :examples

#
# METRICS
#

metrics_tasks = []

begin
  require 'flog_task'
  FlogTask.new do |t|
    t.threshold = 800
    t.dirs = ['lib']
    t.verbose = true
  end
  metrics_tasks << :flog
rescue LoadError
  warn 'flog_task unavailable'
end

begin
  require 'flay_task'
  FlayTask.new do |t|
    t.dirs = ['lib']
    t.verbose = true
  end
  metrics_tasks << :flay
rescue LoadError
  warn 'flay_task unavailable'
end

begin
  require 'roodi_task'
  RoodiTask.new config: '.roodi.yml', patterns: ['lib/**/*.rb']
  metrics_tasks << :roodi
rescue LoadError
  warn "roodi_task unavailable"
end

desc "Generate code metrics reports"
task code_metrics: metrics_tasks

#
# PROFILING
#

desc "Show current system load"
task "loadavg" do
  puts "/proc/loadavg %s" % (File.read("/proc/loadavg") rescue "Unavailable")
end

def lib_sh(cmd)
  sh "RUBYLIB=lib #{cmd}"
end

def rprof_sh(script, args = '', rprof_args = '')
  lib_sh ['ruby-prof', rprof_args, script, '--', args].join(' ')
end

scripts = ["examples/binary_tree.rb", "examples/heap.rb"]

desc "Run ruby-prof on examples/"
task "ruby-prof" => "loadavg" do
  scripts.each { |script| rprof_sh script }
end

desc "Run ruby-prof on examples/ with --exclude-common-cycles"
task "ruby-prof-exclude" => "loadavg" do
  scripts.each { |script| rprof_sh script, "", "--exclude-common-cycles" }
end

#
# GEM BUILD / PUBLISH
#

begin
  require 'buildar'

  Buildar.new do |b|
    b.gemspec_file = 'compsci.gemspec'
    b.version_file = 'VERSION'
    b.use_git = true
  end
rescue LoadError
  warn "buildar tasks unavailable"
end
