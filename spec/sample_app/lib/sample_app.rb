require 'fileutils'
require File.expand_path('../../config/boot', __FILE__)

current_path = File.dirname(__FILE__)

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

    # For checking Wrest Timeouts
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


    # File uploads
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

    # XML deserialise
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


    # Redirection
    get '/redirect_n_times/:times' do
      times       = (params[:times] || 1).to_i

      # Put in a "Moved Permanently" redirect into the mix.
      status_code = (times == 2) ? 301 : 302

      if times > 0
        redirect "/redirect_n_times/#{times-1}", status_code
      else
        "You've reached the end of redirection. There is only darkness beyond this."
      end
    end


    ## Caching

    # Non cacheable
    get '/non_cacheable/nothing_explicitly_specified' do
      "This response does not have any cache headers. Wrest will not cache this."
    end

    get '/non_cacheable/non_cacheable_statuscode' do
      status 401 # Unauthorized
      "Responses with this status code will not be cached."
    end

    get '/non_cacheable/no_store' do
      headers "Cache-Control" => "no-store"

      "This response has a Cache-Control: no-store. Wrest will not cache this."
    end

    get '/non_cacheable/no_cache' do
      headers "Cache-Control" => "no-cache"

      "This response has a Cache-Control: no-cache. Wrest will not cache this."
    end

    get '/non_cacheable/with_etag' do
      headers "Date" => Time.now.httpdate
      headers "Etag" => "1234"

      "This response has a Date and Etag. But without a max-age/Expires header, it can't be cached.
      Remember, Etag and Last-Modified can be used only for validation of cacheable entries after they expire."
    end

    # Cacheable but not validatable
    get '/cacheable/cant_be_validated/with_expires/:seconds_to_cache' do
      headers "Date" => Time.now.httpdate
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response)
       There is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    get '/cacheable/cant_be_validated/with_max_age/:seconds_to_cache' do
      headers "Date" => Time.now.httpdate
      headers "Cache-Control" => "max-age=#{params[:seconds_to_cache]}"

      "#{rand(1000).to_s} (random value to identify a fresh response)
      There is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    get '/cacheable/cant_be_validated/with_both_max_age_and_expires/:seconds_to_cache' do
      headers "Date" => Time.now.httpdate
      headers "Cache-Control" => "max-age=#{params[:seconds_to_cache]}"
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response)
      There is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    # NOTE: The expiry times (1,2 sec intervals) maybe affected and will yield incorrect results when debugging/single-stepping through code. 

    get '/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/:seconds_to_cache' do

      headers "Last-Modified" => Time.now.httpdate
      headers "Date" => Time.now.httpdate
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response)
      When the cache entry at the client expires, it will send a GET request with an If-Modified-Since. But this URI will never validate and always sends a new response"
    end

    get '/cacheable/can_be_validated/with_etag/always_give_fresh_response/:seconds_to_cache' do

      headers "ETAG" => "1234"
      headers "Date" => Time.now.httpdate
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response)
      When the cache entry at the client expires, it will send a GET request with an If-Modified-Since. But this URI will never validate and always sends a new response"
    end


    get '/cacheable/can_be_validated/with_last_modified/always_304/:seconds_to_cache' do

      if request_headers.include? "if_modified_since"
        headers "Last-Modified" => request_headers["if_modified_since"]
        headers "header-that-changes-everytime" => (rand(10000)+1).to_s
        status 304
      else
        headers "Last-Modified" => Time.now.httpdate
        headers "Header-that-was-in-the-first-response" => "42"
      end

      headers "Date" => Time.now.httpdate
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response) 
      When the cache entry at the client expires, it will send a GET request with an If-Modified-Since. This URI will always respond to any validation request with a Not-Modified "
    end

    get '/cacheable/can_be_validated/with_etag/always_304/:seconds_to_cache' do

      status 304 if request_headers.include? "if_none_match"

      headers "ETAG" => "1234"
      headers "Date" => Time.now.httpdate
      headers "Expires" => (Time.now+params[:seconds_to_cache].to_i).httpdate

      "#{rand(1000).to_s} (random value to identify a fresh response)
      When the cache entry at the client expires, it will send a GET request with an If-Modified-Since. This URI will always respond to any validation request with a Not-Modified "
    end

  end
end
