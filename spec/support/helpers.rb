# frozen_string_literal: true
module Helpers
  def self.xml_backends
    backends = %w[Nokogiri REXML]
    unless RUBY_PLATFORM =~ /java/ || (Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/)
      backends << 'LibXML'
    end
    backends
  end
end
