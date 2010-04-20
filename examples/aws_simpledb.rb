# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require 'pp'
require 'openssl'
require 'time'
require "base64"

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG  # Set this to Logger::INFO or higher to disable request logging

# AWS SDB API Reference
# http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/index.html?SDB_API.html

module SimpleDB
  Config = {
    :aws_access_key_id => 'AKIAJOTOWFTQ6FRQIZZA',
    :aws_secret_access_key => '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'
  }
  Uri = "https://sdb.amazonaws.com".to_uri
  Digest  = OpenSSL::Digest::Digest.new('sha1')
  
  extend self
  def invoke(action)
    options = {
      'Action' => action,
      'AWSAccessKeyId' => SimpleDB::Config[:aws_access_key_id],
      'DomainName' => 'LEDev',
      'SignatureVersion' => '2',
      'SignatureMethod' => 'HmacSHA256',
      'Timestamp' => Time.now.iso8601,
      'Version' => '2009-04-15'
    }
    Uri.get(options.merge('Signature' => signature_for(options)))
  end
  
  # http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/index.html?REST_RESTAuth.html
  def signature_for(options)
    data = [
      "GET",
      "sdb.amazonaws.com",
      options.keys.sort.map{|k| "#{k}=#{CGI::escape(options[k])}"}.join('&')
    ].join("\n")
    CGI::escape(Base64.encode64(OpenSSL::HMAC.digest(Digest, Config[:aws_secret_access_key], data)))
  end
  
  def list_domains
    invoke('ListDomains').body
  end
end


pp SimpleDB.list_domains