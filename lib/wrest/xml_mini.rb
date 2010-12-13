require 'wrest/xml_mini/libxml'
require 'wrest/xml_mini/rexml'
require 'wrest/xml_mini/nokogiri'
module ActiveSupport
  module XmlMini
    delegate :filter, :to => :backend
  end
end


