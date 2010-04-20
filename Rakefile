# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# Note that some optional libraries/gems that the build (not Wrest itself) uses may not be available on all implementations of Ruby.
puts "Building on Ruby #{RUBY_VERSION}, #{RUBY_RELEASE_DATE}, #{RUBY_PLATFORM}"

if Object.const_defined?('RAILS_ROOT')
  require File.dirname(__FILE__) + '/../../../config/environment'
else
  require 'rubygems'
  gem 'rspec'
  require 'rake'
  require 'spec'
  require 'spec/rake/spectask'

  begin
    require 'metric_fu'
  rescue LoadError
    puts 'metric_fu is not available. Install it with: gem install jscruggs-metric_fu -s http://gems.github.com'
  end
end

desc 'Default: run spec tests.'
task :default => 'spec:unit'

namespace :spec do
  desc "Run all unit specs"
  Spec::Rake::SpecTask.new(:unit) do |task|
    task.spec_files = FileList['spec/unit/wrest/**/*_spec.rb']
    task.spec_opts = ['--options', 'spec/spec.opts']
  end
  
  desc "Run all live functional specs"
  Spec::Rake::SpecTask.new(:functional) do |task|
    task.spec_files = FileList['spec/functional/wrest/**/*_spec.rb']
    task.spec_opts = ['--options', 'spec/spec.opts']
  end
end

begin
  require 'hanna/rdoctask'
rescue LoadError
  puts 'Hanna not available, using standard Rake rdoctask. Install it with: gem install mislav-hanna.'
  require 'rake/rdoctask'
end
desc 'Generate documentation for Wrest'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Wrest Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rcov'
  require 'rcov/rcovtask'
  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList["spec/unit/wrest/**/*_spec.rb"]
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
    # t.verbose = true
  end
rescue LoadError
  puts "Rcov not available."
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
      # p Rake::FileList['spec/functional/**/*']
    gemspec.name = "wrest"
    gemspec.summary = "REST client library for Ruby."
    gemspec.description = "Wrest is a HTTP and REST client library which allows you to quickly build well encapsulated, object oriented wrappers around any web service."
    gemspec.authors = ["Sidu Ponnappa"]
    gemspec.email = "ckponnappa@gmail.com"
    gemspec.homepage = "http://github.com/kaiwren/wrest"
    gemspec.has_rdoc = true
    gemspec.rubyforge_project = 'wrest'
    gemspec.executables = ['wrest', 'jwrest']
    gemspec.require_path = "lib"
    gemspec.files.exclude *['.gitignore', 'spec/functional']
    gemspec.test_files.exclude *['.gitignore', 'spec/functional', 'examples']
    gemspec.add_dependency('activesupport', '>= 2.3.5')
    case RUBY_PLATFORM
    when /java/
      gemspec.add_dependency('json-jruby', '>= 1.1.3')
      gemspec.add_dependency('nokogiri', '>= 1.3.3')
      gemspec.platform = 'java'
    else
      gemspec.add_dependency('json', '>= 1.1.3')
      gemspec.platform = Gem::Platform::RUBY
    end
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install technicalpickles-jeweler -s http://gems.github.com"
  puts "If you're using JRuby and are having trouble installing jeweler, try installing the git (gem install git) and rubyforge (gem install rubyforge) gems by hand. Also remember to update gems itself (jruby -S gem update --system)."
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
        File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/wrest/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end


namespace (:benchmark) do
  desc "Create classes to be used in Wrest::Resource vs. ActiveResource"
  task :setup_test_classes do
    require 'active_resource'
    require 'lib/wrest'

    class Ooga < Wrest::Resource::Base
    end
    class Booga < ActiveResource::Base 
      self.site=''
    end
  end

  desc "Benchmark when objects are created each time before getting data; i.e there are few queries per instantiation"
  task :create_and_get => :setup_test_classes do |t|

    n = 10000
    puts "Running #{n} times per report"
    Benchmark.bmbm(10) do |rpt|
      rpt.report("Wrest::Resource") do
        n.times {
          ooga = Ooga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')
          ooga.profession
          ooga.profession?
          ooga.enhanced_by
          ooga.enhanced_by?
        }
      end

      rpt.report("ActiveResource") do
        n.times {
          booga = Booga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')
          booga.profession
          booga.profession?
          booga.enhanced_by
          booga.enhanced_by?
        }
      end
    end
  end

  desc "Benchmark when objects are created beforehand; i.e there are many queries per instantiation"
  task :create_once_and_get => :setup_test_classes do |t|

    n = 10000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report("Wrest::Resource") do
        ooga = Ooga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')

        n.times {
          ooga.profession
          ooga.profession?
          ooga.enhanced_by
          ooga.enhanced_by?
        }
      end

      rpt.report("ActiveResource") do
        booga = Booga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')

        n.times {
          booga.profession
          booga.profession?
          booga.enhanced_by
          booga.enhanced_by?
        }
      end
    end
  end

  desc "Benchmark objects respond_to? performance without invocation"
  task :responds_to_before => :setup_test_classes do |t|

    n = 10000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report("Wrest::Resource") do
        ooga = Ooga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')

        n.times {
          ooga.respond_to?(:profession)
          ooga.respond_to?(:profession?)
          ooga.respond_to?(:profession=)
        }
      end

      rpt.report("ActiveResource") do
        booga = Booga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')

        n.times {
          booga.respond_to?(:profession)
          booga.respond_to?(:profession?)
          booga.respond_to?(:profession=)
        }
      end
    end
  end

  desc "Benchmark objects respond_to? performance after invocation"
  task :responds_to_after => :setup_test_classes do |t|

    n = 10000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report("Wrest::Resource") do
        ooga = Ooga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')
        ooga.profession
        ooga.profession?
        ooga.profession = ''

        n.times {
          ooga.respond_to?(:profession)
          ooga.respond_to?(:profession?)
          ooga.respond_to?(:profession=)
        }
      end

      rpt.report("ActiveResource") do
        booga = Booga.new(:id => 5, :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')
        booga.profession
        booga.profession?
        booga.profession = ''

        n.times {
          booga.respond_to?(:profession)
          booga.respond_to?(:profession?)
          booga.respond_to?(:profession=)
        }
      end
    end
  end  
  
  desc "Benchmark keepalive connections (needs functional/sample_rails_app running with class-caching on and keep-alive enabled)"
  task :keep_alive => :setup_test_classes do
    n = 20
    Wrest.logger = Logger.new(File.open("log/benchmark.log", 'a'))
    Benchmark.bmbm(10) do |rpt|
      rpt.report("Fresh connections (Connection: Close)") do
        n.times {
          'http://localhost:3000/headers'.to_uri.get
          'http://localhost:3000/lead_bottles.xml?owner=Kai&type=bottle'.to_uri.get
        }
      end
      
      rpt.report("Keep-alive connection (Connection: Keep-Alive)") do
        Wrest::Native::Session.new('http://localhost:3000'.to_uri) do |session|
          n.times {
            session.get '/headers'
            session.get '/lead_bottles.xml'
          }
        end
      end
    end
  end

  desc "Benchmark xml deserialisation"
  task :deserialise_xml => :setup_test_classes do |t|
    n = 100
    puts "Deserialising using #{ActiveSupport::XmlMini.backend}"
    
    Benchmark.bmbm(10) do |rpt|
      rpt.report("Hash.from_xml") do
        n.times {
          Hash.from_xml(serialised_data)
        }
      end
    end
  end
    
  def serialised_data
      <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
    <business-units type="array">
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:33Z</created-at>
        <department>FooMeh</department>
        <id type="integer">1</id>
        <client-number>0001</client-number>
        <updated-at type="datetime">2008-08-27T16:21:33Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>1</account-number>
            <created-at type="datetime">2008-08-27T16:21:33Z</created-at>
            <id type="integer">1</id>
            <client-id type="integer">1</client-id>
            <updated-at type="datetime">2008-08-27T16:21:33Z</updated-at>
            <client-number>0001</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T18:35:22Z</created-at>
        <department>BoogaBooga</department>
        <id type="integer">32479</id>
        <client-number>0002</client-number>
        <updated-at type="datetime">2008-08-27T18:35:37Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>0</account-number>
            <created-at type="datetime">2008-08-27T18:36:07Z</created-at>
            <id type="integer">32479</id>
            <client-id type="integer">32479</client-id>
            <updated-at type="datetime">2008-08-27T18:36:12Z</updated-at>
            <client-number>0002</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:33Z</created-at>
        <department>Engineering</department>
        <id type="integer">2</id>
        <client-number>000101</client-number>
        <updated-at type="datetime">2008-08-27T16:21:33Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>101</account-number>
            <created-at type="datetime">2008-08-27T16:21:33Z</created-at>
            <id type="integer">2</id>
            <client-id type="integer">2</client-id>
            <updated-at type="datetime">2008-08-27T16:21:33Z</updated-at>
            <client-number>000101</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">3</id>
        <client-number>0001000</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>31974</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">3</id>
            <client-id type="integer">3</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001000</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">4</id>
        <client-number>0001001</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>656064</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">4</id>
            <client-id type="integer">4</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001001</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">5</id>
        <client-number>0001002</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>619842</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">5</id>
            <client-id type="integer">5</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001002</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">6</id>
        <client-number>0001003</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>694370</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">6</id>
            <client-id type="integer">6</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001003</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">7</id>
        <client-number>0001004</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>29284</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">7</id>
            <client-id type="integer">7</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001004</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">8</id>
        <client-number>0001005</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>21285</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">8</id>
            <client-id type="integer">8</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001005</client-number>
          </account>
        </accounts>
      </business-unit>
      <business-unit>
        <company>OogaInc</company>
        <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
        <department></department>
        <id type="integer">9</id>
        <client-number>0001006</client-number>
        <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
        <accounts type="array">
          <account>
            <account-number>638772</account-number>
            <created-at type="datetime">2008-08-27T16:21:34Z</created-at>
            <id type="integer">9</id>
            <client-id type="integer">9</client-id>
            <updated-at type="datetime">2008-08-27T16:21:34Z</updated-at>
            <client-number>0001006</client-number>
          </account>
        </accounts>
      </business-unit>
    </business-units>
    EOXML
  end
end
