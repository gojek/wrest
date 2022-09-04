# frozen_string_literal: true

begin
  gem 'redis', '~> 3'
rescue Gem::LoadError => e
  Wrest.logger.debug 'Redis ~> 3 not found. The Redis gem is necessary to use redis as a caching back-end.'
  raise e
end

require 'redis'
require 'yaml'

module Wrest
  module Caching
    class Redis
      def initialize(redis_options = {})
        @redis = ::Redis.new(redis_options)
      end

      def [](key)
        value = @redis.get(key)
        value.nil? ? nil : YAML.load(value)
      end

      def []=(key, response)
        marshalled_response = YAML.dump(response)
        @redis.set(key, marshalled_response)
        @redis.expire(key, response.freshness_lifetime) unless response.expired?
      end

      def delete(key)
        value = self[key]
        @redis.del(key)
        value
      end
    end
  end
end
