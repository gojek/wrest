module Factories
  def build_ordered_hash(tuples)
    ActiveSupport::OrderedHash.new.tap do |hash|
      tuples.each do |key, value|
        hash[key] = value
      end
    end
  end

  def build_ok_response(body = '', headers = {})
    build_response('200','OK',body, headers)
  end

  def build_response(code,message = '', body = '', headers = {})
    mock(Net::HTTPOK).tap do |response|
      response.stub!(:code).and_return(code)
      response.stub!(:message).and_return(message)
      response.stub!(:body).and_return(body)
      response.stub!(:http_version).and_return("1.1")
      response.stub!(:to_hash).and_return(headers)
      response.stub!('[]').and_return(nil)
      headers.each{|k,v|
        response.stub!('[]').with(k).and_return(v)
      }
    end
  end

  def format_date_in_rfc822_format(date)
    date.in_time_zone('UTC').strftime('%a, %d %b %Y %H:%M:%S %Z')
  end

  # Return a Hash of headers that are HTTP cacheable and will expire in 30 minutes, has Date to be current time, Age 0 and Last Modified ten minutes early.
  def cacheable_headers
    half_hour_after = (Time.now + (60*30)).httpdate
    ten_mins_early  = (Time.now - (10*30)).httpdate

    # All responses in the caching block returns a cacheable response by default
    headers         = {"date" => Time.now.httpdate, "expires" => half_hour_after, "age" => "0", "last-modified" => ten_mins_early}
    headers
  end
end