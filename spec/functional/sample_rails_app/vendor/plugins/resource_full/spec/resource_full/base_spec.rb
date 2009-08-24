require File.dirname(__FILE__) + '/../spec_helper'
 
describe ResourceFull::Base, :type => :controller do
  controller_name "resource_full_mocks"
 
  it "infers the name of its resource model from its class name" do
    controller.model_name.should == "resource_full_mock"
  end
 
  it "infers the class of its resource model from its class name" do
    controller.model_class.should == ResourceFullMock
  end
 
  class ResourceFullFake; end
 
  it "exposes a particular resource model given a symbol" do
    controller.class.exposes :resource_full_fake
    controller.model_class.should == ResourceFullFake
    controller.class.exposes :resource_full_mock # cleanup
  end
 
  it "exposes a particular resource model given a pluralized symbol" do
    controller.class.exposes :resource_full_fakes
    controller.model_class.should == ResourceFullFake
    controller.class.exposes :resource_full_mock # cleanup
  end
 
  it "exposes a particular resource model given a class" do
    controller.class.exposes ResourceFullFake
    controller.model_class.should == ResourceFullFake
    controller.class.exposes ResourceFullMock # cleanup
  end
 
  it "renders two formats by default" do
    controller.class.allowed_formats.should include(:xml, :html)
  end
 
  it "allows you to specify what formats to render" do
    controller.class.responds_to :xml, :json
    controller.class.allowed_formats.should include(:xml, :json)
    controller.class.allowed_formats.should_not include(:html)
  end
 
  class NonResourcesController < ActionController::Base; end
  class ResourcesController < ResourceFull::Base; end
 
  it "knows about all controller subclasses of itself" do
    ActionController::Routing.expects(:possible_controllers).at_least_once.returns %w{resources non_resources}
    ResourceFull::Base.all_resources.should include(ResourcesController)
    ResourceFull::Base.all_resources.should_not include(NonResourcesController)
  end
 
  it "serializes the notion of a resource controller as XML" do
    ResourceFullMockUsersController.clear_queryable_params!
    ResourceFullMockUsersController.queryable_with :first_name
    xml = Hash.from_xml(ResourceFullMockUsersController.to_xml)
    xml["resource"]["name"].should == "resource_full_mock_users"
    xml["resource"]["parameters"].first["name"].should == "first_name"
  end
 
  it "has a default value of :id for the resource identifier column" do
    ResourceFullMockUsersController.resource_identifier.should == :id
  end
 
  it "allows you to set the resource_identifier field" do
    controller.class.identified_by :first_name
    controller.class.resource_identifier.should == :first_name
    controller.class.resource_identifier = :id # cleanup
  end
 
  it "is paginatable by default" do
    controller.class.should be_paginatable
  end
  
  it "translates a model name into a controller constant" do
    ResourceFull::Base.controller_for("resource_full_mock_users").should == ResourceFullMockUsersController
  end
  
  it "raises ResourceNotFound if it cannot constantize the requested controller" do
    lambda do 
      ResourceFull::Base.controller_for("nonsense")
    end.should raise_error(ResourceFull::ResourceNotFound, "not found: nonsense")
  end
  
  it "returns the controller it's been given if it receives a Class object" do
    ResourceFull::Base.controller_for(ResourceFullMockUsersController).should == ResourceFullMockUsersController
  end  
end