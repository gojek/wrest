require File.expand_path('../../config/boot', __FILE__)

module SampleApp
  class Application < Sinatra::Application
    helpers do
      def request_headers
        env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
      end
    end
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
      response.headers["Content-Type"] = 'application/json'
      {
        'parameters' => request.params,
        'headers' => request_headers,
        'file' => params[:file][:tempfile].read
      }.to_json
    end

    get '/redirect_n_times/:times' do
      times = (params[:times] || 1).to_i

      # Put in a "Moved Permanently" redirect into the mix.
      status_code = (times == 2) ? 301 : 302

      if times > 0
        redirect "/redirect_n_times/#{times-1}", status_code
      else
        "You've reached the end of redirection. There is only darkness beyond this."
      end
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