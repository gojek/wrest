# frozen_string_literal: true
module Factories
  def build_ordered_hash(tuples)
    ActiveSupport::OrderedHash.new.tap do |hash|
      tuples.each do |key, value|
        hash[key] = value
      end
    end
  end

  def build_ok_response(body = '', headers = {})
    build_response('200', 'OK', body, headers)
  end

  def build_response(code, message = '', body = '', headers = {})
    double(Net::HTTPOK).tap do |response|
      allow(response).to receive(:code).and_return(code)
      allow(response).to receive(:message).and_return(message)
      allow(response).to receive(:body).and_return(body)
      allow(response).to receive(:http_version).and_return('1.1')
      allow(response).to receive(:to_hash).and_return(headers)
      allow(response).to receive('[]').and_return(nil)
      headers.each do |k, v|
        allow(response).to receive('[]').with(k).and_return(v)
      end
    end
  end

  def format_date_in_rfc822_format(date)
    date.in_time_zone('UTC').strftime('%a, %d %b %Y %H:%M:%S %Z')
  end

  # Return a Hash of headers that are HTTP cacheable and will expire in 30 minutes, has Date to be current time, Age 0 and Last Modified ten minutes early.
  def cacheable_headers
    half_hour_after = (Time.now + (60 * 30)).httpdate
    ten_mins_early  = (Time.now - (10 * 30)).httpdate

    # All responses in the caching block returns a cacheable response by default
    { 'date' => Time.now.httpdate, 'expires' => half_hour_after, 'age' => '0',
      'last-modified' => ten_mins_early }
  end
end
