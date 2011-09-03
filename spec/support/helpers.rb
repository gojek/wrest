module Helpers
  def self.xml_backends
    backends = ['Nokogiri','REXML']
    backends << 'LibXML' unless (RUBY_PLATFORM =~ /java/ || (Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/))
    backends
  end
end