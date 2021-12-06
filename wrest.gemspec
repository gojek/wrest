lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'wrest/version'

Gem::Specification.new do |s|
  s.name        = "wrest"
  s.version     = Wrest::VERSION
  s.authors     = ["Sidu Ponnappa", "Niranjan Paranjape"]
  s.email       = ["ckponnappa@gmail.com"]
  s.homepage    = "https://github.com/gojek-engineering/wrest"
  s.summary     = "Wrest is a fluent, object oriented HTTP client library for 2.x.x, JRuby 9.x"
  s.description = "Wrest is a fluent, easy-to-use, object oriented Ruby HTTP/REST client library with support for RFC2616 HTTP caching, multiple HTTP backends and async calls. It runs on CRuby and JRuby and is in production use at substantial scale."

  s.required_rubygems_version = ">= 1.3.0"
  s.rubyforge_project = "wrest"

  s.requirements << "To use Memcached as caching back-end, install the 'dalli' gem."
  s.requirements << "To use Redis as caching back-end, install the 'redis' gem."
  s.requirements << "To use multipart post, install the 'multipart-post' gem."
  s.requirements << "To use eventmachine as a parallel backend, install the 'eventmachine' gem."

  s.files             = Dir.glob("{bin/**/*,lib/**/*.rb}") + %w(README.md CHANGELOG LICENCE)
  s.extra_rdoc_files  = ["README.md"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.executables       = ['wrest']
  s.require_path      = 'lib'

  # Test dependencies
  s.add_development_dependency "rspec", ["~> 3.3"]
  s.add_development_dependency "sinatra", ["~> 1.0.0"]

  s.add_runtime_dependency "activesupport", [">= 5"]
  s.add_runtime_dependency "builder", ["> 2.0"]
  s.add_runtime_dependency "multi_json", ["~> 1.0"]
  s.add_runtime_dependency "concurrent-ruby", ["~> 1.0"]
  s.add_runtime_dependency "json", ["~> 2.0"]

  case RUBY_PLATFORM
  when /java/
    s.add_runtime_dependency("jruby-openssl", ["~> 0.9"])
    s.platform    = Gem::Platform::CURRENT
  end
end
