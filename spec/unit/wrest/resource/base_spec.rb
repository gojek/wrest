require File.dirname(__FILE__) + '/../../spec_helper'

class Glassware < Wrest::Resource::Base
  set_host "http://localhost:3000"
end

class BottledUniverse < Glassware
  set_host            "http://localhost:3001"
  set_default_format  :xml
end

module Wrest
  describe Wrest::Resource::Base do
    it "should not affect other classes when setting up its macros" do
      Class.should_not respond_to(:host=)
      Object.should_not respond_to(:host=)
    end

    it "should not affect itself when subclasses use its macros" do
      Resource::Base.should_not respond_to(:host)
    end

    describe 'subclasses' do
      before(:each) do
        @BottledUniverse = Class.new(Wrest::Resource::Base)
        @BottledUniverse.class_eval do
          set_resource_name 'BottledUniverse'
        end
      end

      describe 'equality' do
        it "should be equal if it is the same instance" do
          universe = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          (universe == universe).should be_true
        end

        it "should be equal if it has the same state" do
          (
          @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1) == @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          ).should be_true
        end

        it "should not be equal to nil" do
          (@BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1) == nil).should be_false
        end

        it "should not be equal if it is not the same class" do
          (
          @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1) == Glassware.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          ).should be_false
        end

        it "should not be equal if it is has a different state" do
          (
          @BottledUniverse.new(:universe_id=>3, :name=>"Wooz", :id=>1) == @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          ).should be_false
        end

        it "should be symmetric" do
          universe_one = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_two = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          (universe_one == universe_one).should be_true
          (universe_two == universe_two).should be_true
        end

        it "should be transitive" do
          universe_one = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_two = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_three = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          (universe_one == universe_two).should be_true
          (universe_two == universe_three).should be_true
          (universe_one == universe_three).should be_true
        end

        it "should ensure that the hashcode is a fixnum" do
          @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1).hash.should be_kind_of(Fixnum)
        end

        it "should ensure that instances with the same ids have the same hashcode" do
          universe_one = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_two = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_one.hash.should == universe_two.hash
        end

        it "should ensure that instances with different ids have the different hashcodes" do
          universe_one = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
          universe_two = @BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>2)
          universe_one.hash.should_not == universe_two.hash
        end
      end

      it "should know its name as a resource by default" do
        BottledUniverse.resource_name.should == 'bottled_universe'
      end

      it "should allow its name as a resource to be configured for anonymous classes" do
        @BottledUniverse.resource_name.should == 'bottled_universe'
      end

      it "should know how to create an instance using deserialised attributes" do
        universe = @BottledUniverse.new "name"=>"Wooz", "id"=>'1', "universe_id"=>nil, 'owner_id'=>nil
        universe.name.should == "Wooz"
        universe.owner_id.should be_nil
        universe.id.should == 1
      end

      it "should allow instantiation with no attributes" do
        lambda{ @BottledUniverse.new }.should_not raise_error
      end

      it "should have a method to set the host url" do
        @BottledUniverse.should respond_to(:set_host)
      end

      it "should have a method to retrive the host url after it is set" do
        @BottledUniverse.class_eval{ set_host "http://localhost:3000" }
        @BottledUniverse.should respond_to(:host)
      end

      it "should know what its site is" do
        @BottledUniverse.class_eval{ set_host "http://localhost:3000" }
        @BottledUniverse.host.should == "http://localhost:3000"
      end

      it "should not use the same string" do
        url = "http://localhost:3000"
        @BottledUniverse.class_eval{ set_host  url }
        url.upcase!
        @BottledUniverse.host.should == "http://localhost:3000"
      end

      it "should know its resource collection name" do
        Glassware.resource_collection_name.should == 'glasswares'
      end

      it "should know its uri template for find one" do
        Glassware.find_one_uri_template.to_uri(
          :host => 'http://localhost:3000', 
          :resource_collection_name => 'glasswares',
          :id => 1,
          :format => 'json'
        ).should == 'http://localhost:3000/glasswares/1.json'.to_uri
      end

      it "should know how to serialise itself to xml" do
        BottledUniverse.new(:name => 'Foo').to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<bottled-universe>\n  <name>Foo</name>\n</bottled-universe>\n"
      end
            
      describe 'finders' do
        # Json =>
        #         body => {"lead_bottle": {"name": "Wooz", "id": 1, "universe_id": null}}
        #         hash => {"lead_bottle"=>{"name"=>"Wooz", "id"=>1, "universe_id"=>nil}}
        # Xml =>
        #         body =>
        #         <?xml version="1.0" encoding="UTF-8"?>
        #         <lead-bottle>
        #           <id type="integer">1</id>
        #           <name>Wooz</name>
        #           <universe-id type="integer" nil="true"></universe-id>
        #         </lead-bottle>
        #         hash =>
        #         {"lead-bottle"=>{"name"=>{"__content__"=>"Wooz"}, "universe-id"=>{"type"=>"integer", "nil"=>"true"}, "id"=>{"__content__"=>"1", "type"=>"integer"}}}
        #         typecast =>
        #         {"lead_bottle"=>{"name"=>"Wooz", "id"=>1, "universe_id"=>nil}}
        it "should know how to find a resource by id" do
          uri = 'http://localhost:3001/bottled_universe/1.xml'.to_uri
          Wrest::Uri.should_receive(:new).with('http://localhost:3001/bottled_universes/1.xml', {}).and_return(uri)
          response = mock(Wrest::Native::Response)
          uri.should_receive(:get).with(no_args).and_return(response)
          response.should_receive(:deserialise).and_return({"bottled-universe"=>{"name"=>{"__content__"=>"Wooz"}, "universe-id"=>{"type"=>"integer", "nil"=>"true"}, "id"=>{"__content__"=>"1", "type"=>"integer"}}})

          BottledUniverse.find(1).should == BottledUniverse.new(:universe_id=>nil, :name=>"Wooz", :id=>1)
        end
      end
    end

    describe 'subclasses of sublasses' do
      it "should configure its host without affecting its superclass" do
        Glassware.host.should == "http://localhost:3000"
        BottledUniverse.host.should == "http://localhost:3001"
      end

      it "should know its resource collection name when it is a subclass of a subclass" do
        BottledUniverse.resource_collection_name.should == 'bottled_universes'
      end
      
      
      it "should know how to create a new resource" do
        uri = mock(Uri)
        mock_http_response = mock(Net::HTTPResponse)
        mock_http_response.stub!(:code).and_return('201')
        mock_http_response.stub!(:content_type).and_return('application/xml')
        mock_http_response.stub!(:body).and_return("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<bottled-universe>\n  <name>Woot</name>\n <id>1</id>\n </bottled-universe>\n")
        
        Uri.should_receive(:new).with("http://localhost:3001/bottled_universes.xml", {}).and_return(uri)
        uri.should_receive(:post).with(
                                      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<bottled-universe>\n  <name>Woot</name>\n</bottled-universe>\n", 
                                      'Content-Type' => 'application/xml'
                                      ).and_return(Wrest::Native::Response.new(mock_http_response))
        ware = BottledUniverse.create(:name => 'Woot')
      end
    end

    describe 'attribute interface' do
      it "should fail when getter methods for attributes that don't exist are invoked" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        lambda{ universe.ooga }.should raise_error(NoMethodError)
      end

      it "should provide getter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.owner.should == 'Kai Wren'
        universe.guardian.should == 'Lung Shan'
      end

      it "should respond to getter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner)
        universe.should respond_to(:guardian)
      end

      it "should not respond to getter methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic)
      end

      it "should create a setter method when one is invoked for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.fu_dog = 'Shiriki'
        universe.attributes[:fu_dog].should == 'Shiriki'
        universe.fu_dog.should == 'Shiriki'
      end

      it "should provide setter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.guardian = 'Effervescent Tiger'
        universe.attributes[:guardian].should == 'Effervescent Tiger'
      end

      it "should respond to setter methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner=)
        universe.should respond_to(:guardian=)
      end

      it "should not respond to setter methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic=)
      end

      it "should return false when query methods for attributes that don't exist are invoked" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.ooga?.should be_false
      end

      it "should provide query methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => nil)
        universe.owner?.should be_true
        universe.guardian?.should be_false
      end

      it "should respond to query methods for attributes" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should respond_to(:owner?)
        universe.should respond_to(:guardian?)
      end

      it "should not respond to query methods for attributes that don't exist" do
        universe = Glassware.new(:owner => 'Kai Wren', :guardian => 'Lung Shan')
        universe.should_not respond_to(:theronic?)
      end
    end
  end
end
