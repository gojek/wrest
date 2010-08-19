require File.dirname(__FILE__) + '/../../spec_helper'

module ResourceFull
  module Controllers
    describe ResourcesController, :type => :controller do
      
      it "finds all resources" do
        get :index, :format => 'xml'
        response.should have_tag('resources>resource') do
          with_tag('name', 'resource_full_mock_users')
          with_tag('name', 'resource_full_mock_addresses')
        end
      end
      
      it "finds a specific resource" do
        get :show, :format => 'xml', :id => 'resource_full_mock_users'
        response.should have_tag('resource>name', 'resource_full_mock_users')
        response.should_not have_tag('resource>name', 'resource_full_mock_addresses')
      end
      
      it "returns a 404 response when the requested resource is not found" do
        get :show, :format => 'xml', :id => 'foo'
        response.body.should have_tag("errors") { with_tag("error", "ResourceFull::ResourceNotFound: not found: foo") }
        response.code.should == '404'
      end
    end
    
  end
end
