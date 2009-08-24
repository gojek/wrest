require File.dirname(__FILE__) + '/../../spec_helper'

# TODO Most of this functionality is covered by more functional tests elsewhere,
# but it would be nice to have better unit-level coverage for specific breakages.
module ResourceFull
  module Query
    describe CustomParameter do
      it "renders itself as XML" do
        xml = CustomParameter.new(:name, ResourceFullMockUsersController, 
          :fuzzy => true, 
          :columns => [:full_name, :username, :email]
        ).to_xml
                
        Hash.from_xml(xml)["parameter"]["fuzzy"].should be_true
        Hash.from_xml(xml)["parameter"]["name"].should == "name"
      end
  
      describe "inferring the correct table" do
    
        it "simply uses the given table if one is specified" do
          CustomParameter.new(:foo, ResourceFullMockUsersController, :table => "users").table.should == "users"
        end
        
        it "uses the table for the given resource if no :from option is specified" do
          CustomParameter.new(:foo, ResourceFullMockUsersController).table.should == "resource_full_mock_users"
        end
        
        it "looks up the table name for the given association if it is direct" do
          CustomParameter.new(:foo, ResourceFullMockUsersController, :from => :resource_full_mock_addresses).table.should == "resource_full_mock_addresses"
        end
        
        it "looks up the table name for the given assocation if it is specified in a hash" do
          CustomParameter.new(:foo, ResourceFullMockAddressesController, :from => { :resource_full_mock_user => :resource_full_mock_employer }).table.should == "resource_full_mock_employers"
        end
    
      end
  
      describe "subclass" do
        it "returns a copy of itself with its table unchanged if the subclass does not use a different table" do
          parameter = ResourceFull::Query::CustomParameter.new(:name, ResourceFullMocksController)
          parameter.subclass(ResourceFullSubMocksController).table.should == "mock"
        end

        it "returns a copy of itself with its table altered if the subclass uses a different table" do
          ResourceFullSubMocksController.exposes :resource_full_mock_user
          parameter = ResourceFull::Query::CustomParameter.new(:name, ResourceFullMocksController)
          parameter.subclass(ResourceFullSubMocksController).table.should == "resource_full_mock_users"
        end
        
        it "returns a copy of itself with its table unchanged if it was originally built with a custom table" do
          parameter = ResourceFull::Query::CustomParameter.new(:name, ResourceFullMocksController, :table => "widgets")
          parameter.subclass(ResourceFullSubMocksController).table.should == "widgets"          
        end
      end
    end
  end
end
