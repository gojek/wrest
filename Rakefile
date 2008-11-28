gem 'rspec'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'spec'
 
desc 'Default: run spec tests.'
task :default => :spec
 
desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |task|
  task.spec_files = FileList['spec/**/*_spec.rb']
  task.spec_opts = ['--options', 'spec/spec.opts']
end
 
desc 'Generate documentation for Wrest'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Nul'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end