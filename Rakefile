# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# Note that some optional libraries/gems that the build (not Wrest itself) uses may not be available on all implementations of Ruby.
puts "Building on Ruby #{RUBY_VERSION}, #{RUBY_RELEASE_DATE}, #{RUBY_PLATFORM}"

require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.setup

require 'rspec/core/rake_task'
require 'rdoc/task'
require 'rubocop/rake_task'

desc 'Default: run spec tests.'
task default: %w[lint:autocorrect_basic_style_issues rspec:unit lint:rubocop]

desc 'Cruise task'
RSpec::Core::RakeTask.new(:cruise) do |t|
  t.rspec_opts = '--format documentation'
end

namespace :lint do
  RuboCop::RakeTask.new

  desc 'List all the broken cops with individual error counts and the total'
  task :list_broken_cops do
    rubocop_log = `bundle exec rubocop`
    cop_name_pattern = %r{([A-Z][a-zA-Z]+/[A-Z][a-zA-Z]+):}
    matches = rubocop_log.scan(cop_name_pattern).flatten
    counts = matches.each_with_object(Hash.new(0)) do |e, h|
      h[e] += 1
    end
    counts.keys.sort.each { |k| puts "#{k}: #{counts[k]}" }
    puts "\n#{counts.keys.length} cops broken!\n"
  end

  desc 'Apply basic linting autocorrection for whitespace and style'
  task :autocorrect_basic_style_issues do
    basic_style_cops = %w[
      Layout/TrailingWhitespace
      Layout/SpaceInsideBlockBraces
      Style/StringLiterals
    ]
    sh("bundle exec rubocop -a --only #{basic_style_cops.join(',')}")
  end
end

namespace :rspec do
  desc 'Run all unit specs'
  task :unit do
    ENV['wrest_functional_spec'] = nil
    Rake::Task['rspec:spec_runner'].invoke
  end

  desc 'Launch the sample_rails_app running at 3000 in test environment needed for the functional tests'
  task :server do
    sample_app_path = File.join(__dir__, 'spec', 'sample_app')
    sh("cd #{sample_app_path}; bundle install")
    sh("bundle exec rackup -E development -p 3000 #{File.join(sample_app_path, 'config.ru')}")
  end

  desc 'Run all live functional specs - requires sample_rails_app running at 3000 in test environment'
  task :functional do
    ENV['wrest_functional_spec'] = 'true'
    Rake::Task['rspec:spec_runner'].invoke
  end

  RSpec::Core::RakeTask.new(:spec_runner) do |task|
    task.pattern = 'spec/wrest/**/*_spec.rb'
  end
end

desc 'Generate documentation for Wrest'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Wrest Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace(:benchmark) do
  desc 'Create class to be used in the benchmarks'
  task :setup_test_classes do
    require 'wrest'

    klass = Class.new
    klass.send(:include, Wrest::Components::Container)
    self.class.send(:const_set, :Ooga, klass)
  end

  desc 'Benchmark when objects are created each time before getting data; i.e there are few queries per instantiation'
  task create_and_get: :setup_test_classes do |_t|
    n = 10_000
    puts "Running #{n} times per report"
    Benchmark.bmbm(10) do |rpt|
      rpt.report('Wrest::Component') do
        n.times do
          ooga = Ooga.new(id: 5, profession: 'Natural Magician', enhanced_by: 'Kai Wren')
          ooga.profession
          ooga.profession?
          ooga.enhanced_by
          ooga.enhanced_by?
        end
      end
    end
  end

  desc 'Benchmark when objects are created beforehand; i.e there are many queries per instantiation'
  task create_once_and_get: :setup_test_classes do |_t|
    n = 10_000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report('Wrest::Component::Container') do
        ooga = Ooga.new(id: 5, profession: 'Natural Magician', enhanced_by: 'Kai Wren')

        n.times do
          ooga.profession
          ooga.profession?
          ooga.enhanced_by
          ooga.enhanced_by?
        end
      end
    end
  end

  desc 'Benchmark objects respond_to? performance without invocation'
  task responds_to_before: :setup_test_classes do |_t|
    n = 10_000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report('Wrest::Component::Container') do
        ooga = Ooga.new(id: 5, profession: 'Natural Magician', enhanced_by: 'Kai Wren')

        n.times do
          ooga.respond_to?(:profession)
          ooga.respond_to?(:profession?)
          ooga.respond_to?(:profession=)
        end
      end
    end
  end

  desc 'Benchmark objects respond_to? performance after invocation'
  task responds_to_after: :setup_test_classes do |_t|
    n = 10_000
    puts "Running #{n} times per report"

    Benchmark.bmbm(10) do |rpt|
      rpt.report('Wrest::Component::Container') do
        ooga = Ooga.new(id: 5, profession: 'Natural Magician', enhanced_by: 'Kai Wren')
        ooga.profession
        ooga.profession?
        ooga.profession = ''

        n.times do
          ooga.respond_to?(:profession)
          ooga.respond_to?(:profession?)
          ooga.respond_to?(:profession=)
        end
      end
    end
  end

  desc 'Benchmark keepalive connections (needs functional/sample_rails_app running with class-caching on and keep-alive enabled)'
  task keep_alive: :setup_test_classes do
    n = 20
    Wrest.logger = Logger.new(File.open('log/benchmark.log', 'a'))
    Benchmark.bmbm(10) do |rpt|
      rpt.report('Fresh connections (Connection: Close)') do
        n.times do
          'http://localhost:3000/headers'.to_uri.get
          'http://localhost:3000/lead_bottles.xml?owner=Kai&type=bottle'.to_uri.get
        end
      end

      rpt.report('Keep-alive connection (Connection: Keep-Alive)') do
        Wrest::Native::Session.new('http://localhost:3000'.to_uri) do |session|
          n.times do
            session.get '/headers'
            session.get '/lead_bottles.xml'
          end
        end
      end
    end
  end

  desc 'Benchmark xml deserialisation'
  task deserialise_xml: :setup_test_classes do |_t|
    serialised_data =
      <<~EOXML
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

    n = 1000
    backends = %w[REXML Nokogiri]
    backends << (RUBY_PLATFORM =~ /java/ ? 'JDOM' : 'LibXML')

    Benchmark.bmbm(1) do |rpt|
      backends.each do |bkend|
        ActiveSupport::XmlMini.backend = bkend
        rpt.report("Hash.from_xml #{ActiveSupport::XmlMini.backend}") do
          n.times do
            Hash.from_xml(serialised_data)
          end
        end
      end
    end
  end
end
