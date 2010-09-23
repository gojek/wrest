require 'wrest/xml_mini/rexml'
module ActiveSupport
  module XmlMini
    delegate :filter, :to => :backend
  end
end


