require File.dirname(__FILE__) + '/../../../config/environment'

require 'rake'
require 'spec/rake/spectask'
require 'rcov/rcovtask'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
end

require 'rcov/version'

Rcov::RcovTask.new do |t|
  t.pattern = "spec/**/_spec.rb"
  t.rcov_opts = [ "--spec-only" ]
  t.output_dir = "coverage"
end
