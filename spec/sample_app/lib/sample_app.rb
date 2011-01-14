require File.expand_path('../../config/boot', __FILE__)

module SampleApp
  class Application < Sinatra::Application

    # almost all caching handlers use seconds_to_cache.
    before do
      if params.include?(:seconds_to_cache)
        params[:seconds_to_cache] = params[:seconds_to_cache].to_i
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
      params[:file][:tempfile].read
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

      "This response has a Date and Expires header. Wrest will cache this for #{params[:seconds_to_cache]} seconds.
       However there is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    get '/cacheable/cant_be_validated/with_max_age/:seconds_to_cache' do
      headers "Date" => Time.now.httpdate
      headers "Cache-Control" => "max-age=#{params[:seconds_to_cache]}"

      "This response has a Date and max-age. Wrest will cache this for #{params[:seconds_to_cache]} seconds.
       However there is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    get '/cacheable/cant_be_validated/with_both_max_age_and_expires/:seconds_to_cache' do
      headers "Date" => Time.now.httpdate
      headers "Cache-Control" => "max-age=#{params[:seconds_to_cache]}"
      headers "Expires" => (Time.now+params[:seconds_to_cache]).httpdate

      "This response has a Date, max-age and Expires. Wrest will cache this for #{params[:seconds_to_cache]}. 
      However there is no Etag/Last-Modified and so the response can't be validated when it expires. A full blown Get request will be sent if this expires."
    end

    # TODO: Cacheable and validatable

  end
end
