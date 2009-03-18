gem 'rspec'
require 'rake'
require 'rake/rdoctask'
require 'spec'
require 'spec/rake/spectask'
require 'rcov'
require 'rcov/rcovtask'
 
desc 'Default: run spec tests.'
task :default => :spec
 
desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |task|
  task.spec_files = FileList['spec/wrest/**/*_spec.rb']
  task.spec_opts = ['--options', 'spec/spec.opts']
end
 
desc 'Generate documentation for Wrest'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'WRest'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all specs in spec directory with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList["spec/wrest/**/*_spec.rb"]
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
  end
  # t.verbose = true
end