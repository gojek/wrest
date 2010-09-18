lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'wrest/version'

Gem::Specification.new do |s|  
  s.name        = "wrest"
  s.version     = Wrest::VERSION::STRING
  s.authors     = ["Sidu Ponnappa", "Niranjan Paranjape"]
  s.email       = ["sidu@c42.in"]
  s.homepage    = "http://c42.in/open_source"
  s.summary     = "Wrest is an elegant, object oriented HTTP client library for 1.8, 1.9, JRuby and Rubinius."
  s.description = "Wrest is a HTTP and REST client library which allows you to quickly build well encapsulated, object oriented wrappers around any web service."
 
  s.required_rubygems_version = ">= 1.3.7"
  s.rubyforge_project = "wrest"
  
  s.requirements << "To use multipart post, install the 'multipart-post' gem."
  s.requirements << "To use curl as the http engine, install the 'patron' gem. This feature is not available (and should be unneccessary) on jruby."
  
  s.files             = Dir.glob("{bin/**/*,lib/**/*.rb}") + %w(README.rdoc CHANGELOG LICENCE)
  s.extra_rdoc_files  = ["README.rdoc"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.executables       = ['wrest']
  s.require_path      = 'lib'

  s.add_development_dependency "rspec", ["~> 2.0.0.beta.22"]
  s.add_runtime_dependency "activesupport", ["~> 3.0.0"]  
  s.add_runtime_dependency "builder", ["~> 2.1.2"]  
  case RUBY_PLATFORM
  when /java/
    s.add_runtime_dependency("json-jruby", ["~> 1.4.3.1"])
    s.add_runtime_dependency("nokogiri", ["~> 1.4.3.1"])
    s.platform    = Gem::Platform::CURRENT
  else
    s.add_runtime_dependency "json", ["~> 1.4.6"]
  end
end
 
