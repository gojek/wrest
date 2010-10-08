if RUBY_PLATFORM =~ /java/
  require "spec_helper"
  require 'wrest/xml_mini/jdom'
  module ActiveSupport 
    describe XmlMini_JDOM, 'filter' do
      before :each do 
        @present_backend = ActiveSupport::XmlMini.backend  
        ActiveSupport::XmlMini.backend='JDOM'

      end
    
      it "should throw a not implented exception when filter command is invoked and ActiveSupport_XmlMini backend is JDOM" do
        lambda{ XmlMini_JDOM.filter("<xmlbody/>","xpath")}.should raise_error(NotImplementedError)
      end

      after :each do
        ActiveSupport::XmlMini.backend = @present_backend
      end

    end
  end
end
