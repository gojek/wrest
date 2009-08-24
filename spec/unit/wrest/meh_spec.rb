require File.dirname(__FILE__) + '/../spec_helper'

class LeadBottle < Wrest::Resource::Base
  set_host "http://localhost:3000"
  set_default_format  :xml
end

describe "Fuctional" do
  it "should ooga" do
    begin
  p "http://localhost:3000/oogas.json".to_uri(:timeout => 1).get.body
rescue Exception => e
  p e.class
end
  end
  
  it "should know how to find by id" do
    bottle = LeadBottle.find(1)
    bottle.class.should == LeadBottle
    bottle.id.should == 1
    bottle.name.should == 'Wooz'
  end

  it "should know  how to save" do
    bottle = LeadBottle.create(:name => 'Meh')
    LeadBottle.find(bottle.id).name.should == 'Meh'
  end

  # p '-----'
  #
  #     "lead_bottles/old/refill.xml".to_uri.post(self.to_xml)
  #     "lead_bottles/refill.xml" :put, :post
  #     "lead_bottles/1.xml"
  #     "lead_bottles.xml"
  #     p LeadBottle.find(:one, 'lead_bottles/')
  #
  #
  #     class Ooga < Wrest::Resource::Base
  #       @state = Wrest::Resource::State
  #       :one => sdhfj
  #       nedf
  #
  #       1) State =>  new, exists, deleted
  #       3) State => valid, invalid
  #       2) Nesting
  #       create_rest_call    :create_ooga,
  #                           :state => {
  #                                       :new => {:path => '/:foo_type/:foo_id/:self.:format?'},
  #                                       :saved => {:path => one_nest_under(Foo)},
  #                                     },
  #                           :transitions
  #                           :methods => [:put, :post]
  #
  #       def put_create_ooga(sub_params)
  #       end
  #     end
  #
  #
  #     uri = UriTemplate.new('/:foo_type/:foo_id/:self.:format?').to_uri(:foo_type => 'default_zone', :foo_id => 1, :self => 'ooga', :format => 'xml')
  #     uri.get(:)

  xit "should woot" do
    resp =  "http://search.yahooapis.com/NewsSearchService/V1/newsSearch".to_uri.get(
    :appid 	=> 'YahooDemo',
    :output => 'xml',
    :query	=> 'India',
    :results=> '3',
    :start	=> '1'
    )
    p resp.code
    p resp.message
    y resp.deserialise_using(Wrest::Translators::Xml)
  end
end
