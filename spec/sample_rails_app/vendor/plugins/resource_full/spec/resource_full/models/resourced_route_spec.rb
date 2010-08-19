require File.dirname(__FILE__) + '/../../spec_helper'

module ResourceFull
  module Models    
    describe ResourcedRoute do
      it "has a verb, name, pattern, and action" do
        ResourcedRoute.new(:controller => "resource_full_mock_users", :verb => "GET").verb.should == "GET"
        ResourcedRoute.new(:controller => "resource_full_mock_users", :name => "users").name.should == "users"
        ResourcedRoute.new(:controller => "resource_full_mock_users", :pattern => "/users").pattern.should == "/users"
        ResourcedRoute.new(:controller => "resource_full_mock_users", :action => "index").action.should == "index"
      end
      
      it "has an associated controller derived from the given string" do
        ResourcedRoute.new(:controller => "resource_full_mock_users").controller.should == ResourceFullMockUsersController
      end
      
      it "has an associated controller derived from the given class" do
        ResourcedRoute.new(:controller => ResourceFullMockUsersController).controller.should == ResourceFullMockUsersController
      end
      
      it "should know if it's a formatted route" do
        ResourcedRoute.new(:controller => "resource_full_mock_users", :name => "formatted_resource_full_mock_users").should be_formatted
      end
      
      class DumbController < ActionController::Base; end
      
      it "should know if it's a resourced route" do
        ResourcedRoute.new(:controller => DumbController).should_not be_resourced
      end
      
      it "should know how to look up its resource" do
        ResourcedRoute.new(:controller => ResourceFullMockUsersController).resource.should == "resource_full_mock_users"
      end
  
      describe "query" do
        it "raises an exception when it can't find a particular route" do
          lambda do 
            ResourcedRoute.find("this route does not exist")
          end.should raise_error(ResourceFull::Models::RouteNotFound)
        end
        
        it "locates a particular named route" do
          route = ResourcedRoute.find :resource_full_mock_users
          route.pattern.should == "/resource_full_mock_users(.:format)?"
          route.verb.should == "GET"
          route.action.should == "index"
          route.controller.should == ResourceFullMockUsersController
        end
        
        it "locates all named routes" do
          ResourcedRoute.find(:all).collect(&:name).should include(:resource_full_mock_users, :new_resource_full_mock_user, :resource_full_mock_addresses)
        end
        
        it "should filter by a particular resource" do
          route_names = ResourcedRoute.find(:all, :resource_id => "resource_full_mock_users").collect(&:name)
          route_names.should include(:resource_full_mock_users)
          route_names.should_not include(:resource_full_mock_addresses)
        end
      end
    end
  end
end