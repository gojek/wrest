require "spec_helper"

module ActiveSupport 
  describe XmlMini_REXML, 'filter' do
    #  before :each do
    #   @test_obj = Object.new
    #   @test_obj.extend(XmlMini_REXML)
    # end
      it "should filter using the given xpath and return the first matching node found" do
      http_response = mock('Http Response')
      http_response.should_receive(:body).and_return("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>")

      XmlMini_REXML.filter(http_response,'//Name').should == "<Name><FirstName>ooga</FirstName></Name>" 
    end
  end
end
