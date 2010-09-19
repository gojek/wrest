require File.expand_path('../../config/boot', __FILE__)

module SampleApp
  class Application < Sinatra::Application
    get '/multiple_response_headers' do
      response.set_cookie('foo', {:value => "bar", :path => '/', :expires => Time.now})
      response.set_cookie('baz', {:value => "woot", :path => '/', :expires => Time.now})
      response.status = '200'
      " "
    end
    
    get '/two_seconds' do
      sleep 2
      '2'
    end
    
    {:get => ["no_body", "nothing"], :post => ["nothing", "no_bodies.:format"]}.each do |method, paths|
      paths.each do |path|
        send(method, "/#{path}") do
          " "
        end
      end
    end

    put '/uploads/1' do
      params[:file][:tempfile].read
    end
    
    post '/uploads' do
      params[:file][:tempfile].read
    end
  end
  
  get '/lead_bottles/1.xml' do
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
<<-BOTTLES_XML
<?xml version="1.0" encoding="UTF-8"?>
<lead-bottle>
  <id type="integer">1</id>
  <name>Wooz</name>
  <universe-id type="integer" nil="true"></universe-id>
</lead-bottle>
BOTTLES_XML
  end
end