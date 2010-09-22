require 'wrest/xml_mini/rexml'
include ActiveSupport::XmlMini

module XmlMini
  delegate :filter, :to => :backend
end

