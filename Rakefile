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

desc "Run type checks (RBS + Steep)"
task :steep do
  bindir = Dir[File.join(ENV['HOME'], '.local/share/gem/ruby/*/bin')].last
  sh "#{File.join(bindir, 'steep')} check"
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

begin
  require 'flog_task'
  FlogTask.new do |t|
    t.threshold = 9000
    t.dirs = ['lib']
    t.verbose = true
  end
rescue LoadError
  # warn 'flog_task unavailable'
end

begin
  require 'flay_task'
  FlayTask.new do |t|
    t.dirs = ['lib']
    t.verbose = true
  end
rescue LoadError
  # warn 'flay_task unavailable'
end

begin
  require 'roodi_task'
  RoodiTask.new config: '.roodi.yml', patterns: ['lib/**/*.rb']
rescue LoadError
  # warn "roodi_task unavailable"
end


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

scripts = [
  "examples/complete_tree.rb",
  "examples/heap.rb",
  "examples/heap_push.rb",
  "examples/tree.rb",
  "examples/flex_node.rb",
  "examples/binary_search_tree.rb",
  "examples/ternary_search_tree.rb",
]

desc "Run ruby-prof on examples/"
task "ruby-prof" => "loadavg" do
  scripts.each { |script| rprof_sh script }
end

desc "Run ruby-prof on examples/ with --exclude-common-cycles"
task "ruby-prof-exclude" => "loadavg" do
  scripts.each { |script| rprof_sh script, "", "--exclude-common-cycles" }
end


#
# REPORTS
#


desc "Generate code metrics and reports"
task report: :test do
  %w{examples bench flog flay roodi ruby-prof ruby-prof-exclude}.each { |t|
    sh "rake #{t} > reports/#{t} 2>&1" do |ok, _status|
      puts "rake #{t} failed" unless ok
    end
  }
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
