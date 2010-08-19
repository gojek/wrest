require File.dirname(__FILE__) + '/../spec_helper'

describe "ResourceFull::Query", :type => :controller do
  controller_name "resource_full_mock_users"
  
  before :all do
    ResourceFullMockUser.delete_all
    @users = [
      ResourceFullMockUser.create!(:resource_full_mock_employer_id => 1, :income => 70_000, :first_name => "guybrush"),
      ResourceFullMockUser.create!(:resource_full_mock_employer_id => 1, :income => 30_000, :first_name => "toothbrush"),
      ResourceFullMockUser.create!(:resource_full_mock_employer_id => 2, :income => 70_000, :first_name => "guthrie"),
    ]
    @guybrush, @toothbrush, @guthrie = @users
  end
  attr_reader :users
  
  before :each do
    ResourceFullMockUsersController.queryable_params = nil
  end
  
  it "isn't queryable on any parameters by default" do
    controller.class.queryable_params.should be_empty
  end
  
  it "allows you to specify queryable parameters" do
    controller.class.queryable_with :resource_full_mock_employer_id, :income
    controller.class.queryable_params.collect(&:name).should include(:resource_full_mock_employer_id, :income)
  end
  
  it "retrieves objects based on a queried condition" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :index, :resource_full_mock_employer_id => 1
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "retrieves no objects if the queried condition is not matched" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :index, :resource_full_mock_employer_id => 3
    assigns(:resource_full_mock_users).should be_empty
  end
  
  it "queries on the intersection of multiple conditions" do
    controller.class.queryable_with :resource_full_mock_employer_id, :income
    get :index, :resource_full_mock_employer_id => 1, :income => 70_000
    assigns(:resource_full_mock_users).should == [ users[0] ]
  end
  
  it "queries multiple values in a comma-separated list" do
    controller.class.queryable_with :resource_full_mock_employer_id, :income
    get :index, :resource_full_mock_employer_id => "1,2"
    assigns(:resource_full_mock_users).should include(*users)
  end
  
  it "queries multiple values in standard request parameter list format" do
    controller.class.queryable_with :resource_full_mock_employer_id, :income
    get :index, :resource_full_mock_employer_id => [ '1', '2' ]
    assigns(:resource_full_mock_users).should include(*users)
  end
  
  it "retrieves objects given pluralized forms of queryable parameters" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :index, :resource_full_mock_employer_ids => "1,2"
    assigns(:resource_full_mock_users).should include(*users)
  end
  
  it "uses LIKE clauses to query if the fuzzy option is specified" do
    controller.class.queryable_with :first_name, :fuzzy => true
    get :index, :first_name => "gu"
    assigns(:resource_full_mock_users).should include(users[0], users[2])
    assigns(:resource_full_mock_users).should_not include(users[1])
  end
  
  it "allows a queryable parameter to map to a different column" do
    controller.class.queryable_with :address, :column => :resource_full_mock_employer_id
    get :index, :address => 1
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "appends to rather than replaces queryable values" do
    controller.class.queryable_with :resource_full_mock_employer_id
    controller.class.queryable_with :income
    
    get :index, :resource_full_mock_employer_id => 1, :income => 70_000
    assigns(:resource_full_mock_users).should include(users[0])
    assigns(:resource_full_mock_users).should_not include(users[1], users[2])
  end
  
  it "counts all objects if there are no parameters" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :count
    Hash.from_xml(response.body)['count'].to_i.should == 3
  end
  
  it "counts the requested objects if there are paramters" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :count, :resource_full_mock_employer_id => 1
    Hash.from_xml(response.body)['count'].to_i.should == 2
  end

  it "counts no objects if there are none with the requested parameters" do
    controller.class.queryable_with :resource_full_mock_employer_id
    get :count, :resource_full_mock_employer_id => 15
    Hash.from_xml(response.body)['count'].to_i.should == 0
  end
  
  it "negates a single queried value" do
    ResourceFullMockUsersController.queryable_with :not_resource_full_mock_employer_id, :negated => true, :column => :resource_full_mock_employer_id
    
    get :index, :not_resource_full_mock_employer_id => 2
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "negates multiple queried values" do
    ResourceFullMockUsersController.queryable_with :not_resource_full_mock_employer_id, :negated => true, :column => :resource_full_mock_employer_id
    
    get :index, :not_resource_full_mock_employer_id => [1, 2]
    assigns(:resource_full_mock_users).should be_empty
  end
  
  it "negates a fuzzy string value" do
    ResourceFullMockUsersController.queryable_with :not_first_name, :negated => true, :column => :first_name, :fuzzy => true
    
    get :index, :not_first_name => "brush"
    assigns(:resource_full_mock_users).should include(@guthrie)
    assigns(:resource_full_mock_users).should_not include(@guybrush, @toothbrush)
  end
  
  it "negates a queried value with a column defined by a proc" do
    ResourceFullMockUsersController.queryable_with :not_resource_full_mock_employer_id, :negated => true, :column => lambda {|id| :resource_full_mock_employer_id}
    
    get :index, :not_resource_full_mock_employer_id => 2
    assigns(:resource_full_mock_users).should include(users[0], users[1])
    assigns(:resource_full_mock_users).should_not include(users[2])
  end
  
  it "negates a queried value and returns all records for which the value is null" do
    ResourceFullMockUsersController.queryable_with :not_resource_full_mock_employer_id, :negated => true, :column => :resource_full_mock_employer_id
    null_user = ResourceFullMockUser.create!
    
    get :index, :not_resource_full_mock_employer_id => [1, 2]
    assigns(:resource_full_mock_users).should == [ null_user ]
  end
  
  it "allows you to specify a default value, which it uses if there is no explicit value given for that parameter" do
    ResourceFullMockUsersController.queryable_with :first_name, :default => "guybrush"
    
    get :index
    assigns(:resource_full_mock_users).should == [ @guybrush ]
  end
  
  it "allows you to override the default value if an explicit value is specified" do
    ResourceFullMockUsersController.queryable_with :first_name, :default => "guybrush"
    
    get :index, :first_name => "toothbrush"
    assigns(:resource_full_mock_users).should == [ @toothbrush ]
  end
  
  describe "with multiple columns" do
    controller_name "resource_full_mock_users"
    
    before :all do
      ResourceFullMockUser.delete_all
      @users = [
        ResourceFullMockUser.create!(:first_name => "guybrush", :last_name => "threepwood"),
        ResourceFullMockUser.create!(:first_name => "herman",   :last_name => "guybrush"),
        ResourceFullMockUser.create!(:first_name => "ghost_pirate", :last_name => "le_chuck")
      ]
    end
    attr_reader :users
    
    before :each do
      ResourceFullMockUsersController.queryable_params = nil
    end
  
    it "allows a queryable parameter to map to multiple columns" do    
      controller.class.queryable_with :name, :columns => [:first_name, :last_name]
      get :index, :name => "guybrush"
      assigns(:resource_full_mock_users).should include(users[0], users[1])
      assigns(:resource_full_mock_users).should_not include(users[2])
    end
  
    it "queries fuzzy values across multiple columns" do
      controller.class.queryable_with :name, :columns => [:first_name, :last_name], :fuzzy => true
      get :index, :name => "gu"
      assigns(:resource_full_mock_users).should include(users[0], users[1])
      assigns(:resource_full_mock_users).should_not include(users[2])
    end
  end
  
  describe "with joins" do
    controller_name "resource_full_mock_addresses"
    
    before :each do
      ResourceFullMockUser.delete_all
      ResourceFullMockAddress.delete_all
      
      @user = ResourceFullMockUser.create! :email => "gthreepwood@melee.gov"
      @valid_addresses = [
        @user.resource_full_mock_addresses.create!,
        @user.resource_full_mock_addresses.create!
      ]
      
      invalid_user = ResourceFullMockUser.create! :email => "blah@blah.com"
      @invalid_address = invalid_user.resource_full_mock_addresses.create!
      
      ResourceFullMockUsersController.resource_identifier = :id
      ResourceFullMockAddressesController.clear_queryable_params!
    end
    attr_reader :user, :valid_addresses, :invalid_address
    
    it "filters addresses by the appropriate column and join if a :from relationship is defined" do
      ResourceFullMockAddressesController.queryable_with :email, :from => :resource_full_mock_user
      
      get :index, :resource_full_mock_user_id => 'foo', :email => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
    
    it "filters addresses by the User resource identifier if a :from is specified along with :resource_identifier" do
      ResourceFullMockUsersController.resource_identifier = :email
      ResourceFullMockAddressesController.queryable_with :resource_full_mock_user_id, :from => :resource_full_mock_user, :resource_identifier => true
            
      get :index, :resource_full_mock_user_id => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
    
    it "filters addresses by the User resource identifier if a :from is specified along with :resource_identifier and the resource identifer is a Proc" do
      ResourceFullMockUsersController.identified_by :email, :unless => :id_numeric
      ResourceFullMockAddressesController.queryable_with :resource_full_mock_user_id, :from => :resource_full_mock_user, :resource_identifier => true
            
      get :index, :resource_full_mock_user_id => user.id
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
    
    it "filters addresses by the Employer resource by specifying a table name and ensuring that the intermediate User resource is included in the query" do
      employer = ResourceFullMockEmployer.create! :name => "Melee Island Dept. of Piracy"
      @user.update_attributes :resource_full_mock_employer => employer
      ResourceFullMockEmployer.create! :name => "Kingdom of Phatt Island"
      
      ResourceFullMockAddressesController.queryable_with :resource_full_mock_employer_name, 
        :from => { :resource_full_mock_user => :resource_full_mock_employer }, 
        :table => 'resource_full_mock_employers',
        :column => :name,
        :fuzzy => true
        
      get :index, :resource_full_mock_employer_name => "Melee"
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
        
    # TODO This is perhaps not the best place for this test.  
    it "filters addresses by the User resource identifer if a controller is said to nest within another controller" do
      ResourceFullMockUsersController.resource_identifier = :email
      ResourceFullMockAddressesController.nests_within(:resource_full_mock_user)
      
      get :index, :resource_full_mock_user_id => user.email
      assigns(:resource_full_mock_addresses).should include(*valid_addresses)
      assigns(:resource_full_mock_addresses).should_not include(invalid_address)
    end
  end
  
  describe "with subclasses" do
    controller_name "resource_full_sub_mocks"
    before :each do
      ResourceFullMocksController.queryable_params    = nil
      ResourceFullSubMocksController.queryable_params = nil
    end
    
    it "allows subclasses to add to the list of queryable parameters" do
      ResourceFullMocksController.queryable_with :foo
      ResourceFullSubMocksController.queryable_with :bar
      ResourceFullSubMocksController.should be_queryable_with(:foo, :bar)      
    end
    
    it "doesn't alter the queryable parameters of a superclass when a subclass" do
      ResourceFullMocksController.queryable_with :foo
      ResourceFullSubMocksController.queryable_with :bar
      ResourceFullMocksController.should_not be_queryable_with(:bar)
    end
        
    it "uses the model and table name of the subclass rather than the superclass when querying" do
      ResourceFullMocksController.queryable_with :first_name
      ResourceFullSubMocksController.exposes :resource_full_mock_users
      ResourceFullMockUser.create! :first_name => "guybrush"
      ResourceFullMock.expects(:find).never
      get :index, :format => 'xml', :first_name => 'guybrush'
      response.body.should have_tag("resource-full-mock-user") { with_tag("first-name", "guybrush") }
    end
  end
  
  describe "with named scope" do
    controller_name "resource_full_mock_users"
    
    it "filters parameter values using the given named scope method if no parameters are given" do
      ResourceFullMockUsersController.queryable_with :born_today, :scope => :born_today
      ResourceFullMockUser.named_scope :born_today, :conditions => { :birthdate => Date.today }
      
      real_user  = ResourceFullMockUser.create! :birthdate => Date.today
      noise_user = ResourceFullMockUser.create! :birthdate => Date.yesterday
      
      get :index, :format => 'xml', :born_today => true
      
      assigns(:resource_full_mock_users).should == [ real_user ]
    end
    
    it "filters parameter values using the given named scope proc if no parameters are given" do
      ResourceFullMockUsersController.queryable_with :born_today, :scope => lambda { {:conditions => { :birthdate => Date.today } } }
      
      real_user  = ResourceFullMockUser.create! :birthdate => Date.today
      noise_user = ResourceFullMockUser.create! :birthdate => Date.yesterday
      
      get :index, :format => 'xml', :born_today => true
      
      assigns(:resource_full_mock_users).should == [ real_user ]
    end
    
    it "filters parameter values using the given named scope hash if no parameters are given" do
      ResourceFullMockUsersController.queryable_with :born_today, :scope => { :conditions => { :birthdate => Date.today } }
      
      real_user  = ResourceFullMockUser.create! :birthdate => Date.today
      noise_user = ResourceFullMockUser.create! :birthdate => Date.yesterday
      
      get :index, :format => 'xml', :born_today => true
      
      assigns(:resource_full_mock_users).should == [ real_user ]
    end
    
    it "filters parameter values using the given named scope method if a parameter is given" do
      ResourceFullMockUser.named_scope :named, lambda { |name| { :conditions => { :first_name => name } } }
      ResourceFullMockUsersController.queryable_with :named, :scope => :named
      
      real_user  = ResourceFullMockUser.create! :first_name => "Guybrush"
      noise_user = ResourceFullMockUser.create! :first_name => "Toothbrush"
      
      get :index, :format => 'xml', :named => "Guybrush"
      
      assigns(:resource_full_mock_users).should == ResourceFullMockUser.named("Guybrush")
    end
    
    it "filters parameter values fuzzily using the given named scope method if a parameter is given and fuzzy is specified" do
      ResourceFullMockUser.named_scope :named, lambda { |name| { :conditions => { :first_name => name } } }
      ResourceFullMockUsersController.queryable_with :named, :scope => :named, :fuzzy => true
      
      real_user  = ResourceFullMockUser.create! :first_name => "Guybrush"
      noise_user = ResourceFullMockUser.create! :first_name => "Toothbrush"
      
      get :index, :format => 'xml', :named => "brush"
      
      assigns(:resource_full_mock_users).should == ResourceFullMockUser.named("%brush%")
    end
    
    it "filters parameter values using multiple named scopes by chaining them together" do
      ResourceFullMockUsersController.queryable_with :born_today,     :scope => :born_today
      ResourceFullMockUsersController.queryable_with :named_guybrush, :scope => :named_guybrush
      
      ResourceFullMockUser.named_scope :born_today,     :conditions => { :birthdate => Date.today }
      ResourceFullMockUser.named_scope :named_guybrush, :conditions => { :first_name => "Guybrush" }
      
      real_user         = ResourceFullMockUser.create! :birthdate => Date.today, :first_name => "Guybrush"
      yesterday_user    = ResourceFullMockUser.create! :birthdate => Date.yesterday, :first_name => "Guybrush"
      toothbrush_user   = ResourceFullMockUser.create! :birthdate => Date.today, :first_name => "Toothbrush"

      get :index, :format => 'xml', :born_today => true, :named_guybrush => true
      
      assigns(:resource_full_mock_users).should == ResourceFullMockUser.born_today.named_guybrush
    end
    
    # I know this works experimentally but have yet to write the test.
    it "combines named scope filters with standard queryable_with parameter filters"
  end
  
  describe "with nils" do
    controller_name "resource_full_mock_users"
    
    before :each do
      ResourceFullMockUser.delete_all
    end
    
    it "finds records when an allow_nil queryable parameter is blank" do
      ResourceFullMockUsersController.queryable_with :resource_full_mock_employer_id, :allow_nil => true
      real_user  = ResourceFullMockUser.create! :first_name => "brian", :resource_full_mock_employer_id => nil
      noise_user = ResourceFullMockUser.create! :first_name => "brian", :resource_full_mock_employer_id => 13
      
      get :index, :resource_full_mock_employer_id => nil
      assigns(:resource_full_mock_users).should == [ real_user ]
    end
    
    it "finds records when an allow_nil queryable parameter contains a value" do
      ResourceFullMockUsersController.queryable_with :resource_full_mock_employer_id, :allow_nil => true
      real_user  = ResourceFullMockUser.create! :first_name => "brian", :resource_full_mock_employer_id => 13
      nil_user   = ResourceFullMockUser.create! :first_name => "brian", :resource_full_mock_employer_id => nil
      wrong_user = ResourceFullMockUser.create! :first_name => "brian", :resource_full_mock_employer_id => 16
      
      get :index, :resource_full_mock_employer_id => 13
      assigns(:resource_full_mock_users).should == [ real_user ]
    end
  end
  
  describe "with sorting" do
    controller_name "resource_full_mock_users"

    before :each do
      ResourceFullMockUsersController.queryable_with_order
      ResourceFullMockUser.delete_all
      
      initech = ResourceFullMockEmployer.create! :name => "Initech", :email => "whatsbestforthecompany@initech.com"
      tworks  = ResourceFullMockEmployer.create! :name => "ThoughtWorks", :email => "info@thoughtworks.com"
      
      eve     = ResourceFullMockUser.create! :first_name => "Eve",   :resource_full_mock_employer => initech, :email => "eve@initech.com"
      alice   = ResourceFullMockUser.create! :first_name => "Alice", :resource_full_mock_employer => initech, :email => "alice@initech.com"
      bob     = ResourceFullMockUser.create! :first_name => "Bob",   :resource_full_mock_employer => tworks,  :email => "bob@thoughtworks.com"

      @ordered_list = [ alice, bob, eve ]
      @company_ordered_list = [ bob, eve, alice ]
    end

    it "should be sortable by the given parameter, in ascending order by default" do    
      get :index, :order_by => "first_name"
      assigns(:resource_full_mock_users).should == @ordered_list
    end

    it "should be sortable by the given parameter in descending order" do
      get :index, :order_by => "first_name", :order_direction => "desc"
      assigns(:resource_full_mock_users).should == @ordered_list.reverse    
    end
    
    it "should not blow up if no order by key is given" do
      lambda do
        get :index
      end.should_not raise_error(ActiveRecord::StatementInvalid)
    end
    
    it "should sort the column with the same table as the resource if no explicit table name is given" do
      ResourceFullMockUsersController.queryable_with :foo, :scope => { :include => :resource_full_mock_employer }, :default => true
      lambda do
        get :index, :order_by => "email"
      end.should_not raise_error(ActiveRecord::StatementInvalid)
      assigns(:resource_full_mock_users).should == @ordered_list
    end
    
    it "should sort the column with the table name corresponding to the given table name" do
      ResourceFullMockUsersController.queryable_with :foo, :scope => { :include => :resource_full_mock_employer }, :default => true
      ResourceFullMockUsersController.orderable_by :email, :from => :resource_full_mock_employer
      
      get :index, :order_by => "email"
      assigns(:resource_full_mock_users).first.email.should == "bob@thoughtworks.com"
    end
    
    it "should be sortable by the given parameter using the given column" do
      ResourceFullMockUsersController.orderable_by :employer_email, :from => :resource_full_mock_employer, :column => 'email'
      
      get :index, :order_by => "employer_email"
      assigns(:resource_full_mock_users).first.email.should == "bob@thoughtworks.com"
    end
  end
  
end