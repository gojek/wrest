require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Dispatch", :type => :controller do
  controller_name "resource_full_mocks"
  
  before(:each) do
    ResourceFullMock.stubs(:find).returns stub(:id => 1)
    # controller.stubs :render
  end
  
  it "exposes a method for skipping format and method protection"
  
  describe "based on request format" do
    controller_name "resource_full_mocks"
    
    after :each do
      controller.class.responds_to :defaults
    end
  
    it "dispatches to index_xml render method if xml is requested" do
      controller.expects(:index_xml)
      get :index, :format => 'xml'
    end
  
    it "dispatches to index_json render method if json is requested" do
      controller.expects(:index_json)
      get :index, :format => 'json'
    end

    it "dispatches to index_html render method if html is requested" do  
      controller.expects(:index_html)
      controller.stubs(:render)
      get :index, :format => 'html'
    end
  
    it "raises a 406 error if it does not respond to a format for which no methods are included" do
      get :index, :format => 'txt'
      response.code.should == '406'
    end
  
    it "raises a 406 error if it does not respond to a format which has been explicitly removed" do
      controller.class.responds_to :xml
      get :index, :format => 'html'
      response.code.should == '406'
    end
    
    it "includes an appropriate error message if it does not respond to a format which has been explicitly removed" do
      controller.class.responds_to :xml
      get :index, :format => 'html'
      response.body.should =~ /Resource does not have a representation in text\/html format/
    end
  end
  
  describe "based on request action" do
    controller_name "resource_full_mocks"
    
    after :each do
      controller.class.responds_to :defaults
    end
    
    it "claims to respond to create, read, update, delete, and count by default" do
      controller.class.responds_to :defaults
      controller.class.allowed_methods.should include(:create, :read, :update, :delete)
    end
    
    it "lists all the standard Rails methods plus count as its possible actions" do
      controller.class.possible_actions.should include(:create, :new, :show, :index, :count, :update, :edit, :destroy)
    end
    
    it "claims to not respond to any methods for an unsupported format" do
      controller.class.responds_to :xml
      controller.class.allowed_methods(:html).should be_empty
    end
    
    it "claims to respond to default methods for a requested format if no explicit methods are given" do
      controller.class.responds_to :xml
      controller.class.allowed_methods(:xml).should include(:create, :read, :update, :delete)
    end
    
    it "claims to respond to only methods given a single value with the :only option" do
      controller.class.responds_to :xml, :only => :read
      controller.class.allowed_methods(:xml).should == [:read]
    end
    
    it "claims to respond to only methods given multiple values with the :only option" do
      controller.class.responds_to :xml, :only => [:read, :delete]
      controller.class.allowed_methods(:xml).should == [:read, :delete]
    end
    
    it "responds successfully to supported methods" do
      controller.class.responds_to :xml, :only => :read
      controller.stubs(:index)
      get :index, :format => "xml"
      response.should be_success
    end
    
    it "disallows unsupported methods with code 405" do
      controller.class.responds_to :html, :only => :read
      controller.stubs(:destroy)
      delete :destroy, :id => 1
      response.code.should == '405'
      response.body.should =~ /Resource does not allow destroy action/
    end
    
    it "ignores and does not verify custom methods" do
      controller.class.responds_to :xml, :only => [:delete]
            
      get :foo, :format => 'xml'
      response.body.should have_tag("foo", "bar")
      response.code.should == '200'
    end
    
    it "allows you to specify the appropriate CRUD semantics of a custom method"
  end
  
  describe "GET index" do
    controller_name "resource_full_mocks"
    
    before :each do
      controller.stubs(:render)
    end
    
    it "sets an @mocks instance variable based on the default finder" do
      ResourceFullMock.stubs(:find).returns "a list of mocks"
      get :index, :format => 'html'
      assigns(:resource_full_mocks).should == "a list of mocks"
    end
    
    it "sets an @mocks instance variable appropriately if the default finder is overridden" do
      begin
        controller.class.class_eval do
          def find_all_resource_full_mocks; "another list of mocks"; end
        end      
        get :index, :format => 'html'
        assigns(:resource_full_mocks).should == "another list of mocks"
      ensure
        controller.class.class_eval do
          undef :find_all_resource_full_mocks
        end
      end
    end    
  end
  
  describe "GET show" do
    controller_name "resource_full_mocks"
    
    before :each do
      controller.stubs(:render)
    end
    
    it "sets a @mock instance variable based on the default finder" do
      ResourceFullMock.stubs(:find).returns "a mock"
      get :show, :id => 1, :format => 'html'
      assigns(:resource_full_mock).should == "a mock"
    end
    
    it "sets a @mock instance variable appropriately if the default finder is overridden" do
      controller.class.class_eval do
        def find_resource_full_mock; "another mock"; end
      end
      get :show, :id => 1, :format => 'html'
      assigns(:resource_full_mock).should == "another mock"
    end
  end
  
  describe "POST create" do
    controller_name "resource_full_mocks"
    
    before :each do
      controller.stubs :render
    end
    
    it "sets a @mock instance variable based on the default creator" do
      ResourceFullMock.stubs(:create).returns stub(:errors => stub_everything, :id => :mock)
      post :create, :format => 'html'
      assigns(:resource_full_mock).id.should == :mock
    end
    
    it "sets a @mock instance variable appropriately if the default creator is overridden" do
      ResourceFullMock.stubs(:super_create).returns stub(:errors => stub_everything, :id => :super_mock)
      controller.class.class_eval do
        def create_resource_full_mock; ResourceFullMock.super_create; end
      end
      post :create, :format => 'html'
      assigns(:resource_full_mock).id.should == :super_mock
    end
  end
  
  describe "PUT update" do
    controller_name "resource_full_mocks"
    
    before :each do
      controller.stubs :render
    end
    
    it "sets a @mock instance variable based on the default updater" do
      ResourceFullMock.stubs(:find).returns stub(:id => 1, :update_attributes => true, :errors => stub_everything)
      put :update, :id => 1, :format => 'html'
      assigns(:resource_full_mock).id.should == 1
    end
    
    it "sets a @mock instance variable appropriately if the default updater is overridden" do
      ResourceFullMock.stubs(:super_update).returns stub(:errors => stub_everything, :id => :super_mock)
      controller.class.class_eval do
        def update_resource_full_mock; ResourceFullMock.super_update; end
      end
      put :update, :id => 1, :format => 'html'
      assigns(:resource_full_mock).id.should == :super_mock
    end
  end
  
  describe "when the user agent is IE7" do
    before :each do
      request.env["HTTP_USER_AGENT"] = "MSIE 7.0"
      controller.stubs(:find_all_resource_full_mocks).returns([])
    end
    
    it "should set the request format to json when the incoming request format looks like json" do
      get :index, :format => 'json-test'
      response.content_type.should == "application/json"
    end
    
    it "should set the request format to json when the incoming request format looks like javascript" do
      get :index, :format => 'javascript-test'
      response.content_type.should == "application/json"
    end
    
    it "should set the request format to json when the incoming request uri looks like json" do
      request.env["REQUEST_URI"] = "/resource_full_mocks.json?foo=bar"
      get :index
      response.content_type.should == "application/json"
    end
    
    it "should set the request format to xml when the incoming request format looks like xml" do
      get :index, :format => 'xml-test'
      response.content_type.should == "application/xml"
    end
    
    it "should set the request format to json when the incoming request uri looks like xml" do
      request.env["REQUEST_URI"] = "/resource_full_mocks.xml?foo=bar"
      get :index
      response.content_type.should == "application/xml"
    end
    
    # Dirk assures me that the following functionality is necessary due to the way Rails handles IE7
    # request formats, or perhaps the way IE7 sends its request content-type.
    # TODO Find a better criterion than 'else, use text/html'.
    it "should default the request format to text/html when the incoming request uri is not supported" do
      controller.stubs :render
      request.env["REQUEST_URI"] = "/resource_full_mocks.png"
      get :index
      response.content_type.should == "text/html"
    end
    
    # See above.
    it "should default the request format to text/html when the incoming request format is not supported" do
      controller.stubs :render
      get :index, :format => "image/png"
      response.content_type.should == "text/html"
    end
  end
end
