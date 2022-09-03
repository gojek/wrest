# frozen_string_literal: true

module Wrest
  class Uri
    # Contains methods that depend on Uri#clone to build
    # new Uris configured in particular ways.
    module Builders
      # Returns a Uri object that uses threads to perform asynchronous requests.
      def using_threads
        clone(asynchronous_backend: Wrest::AsyncRequest::ThreadBackend.new)
      end

      # Returns a Uri object that uses eventmachine to perform asynchronous requests.
      # Remember to do Wrest::AsyncRequest.enable_em first so that
      # EventMachine is available for use.
      def using_em
        clone(asynchronous_backend: Wrest::AsyncRequest::EventMachineBackend.new)
      end

      # Returns a Uri object that uses hash for caching responses.
      def using_hash
        clone(cache_store: {})
      end

      # Returns a Uri object that uses memcached for caching responses.
      # Remember to do Wrest::AsyncRequest.enable_memcached first so that
      # memcached is available for use.
      def using_memcached
        clone(cache_store: Wrest::Caching::Memcached.new)
      end

      def using_redis
        clone(cache_store: Wrest::Caching::Redis.new)
      end

      # Disables using the globally configured cache for GET requests
      # made using the Uri returned by this method.
      def disable_cache
        clone(disable_cache: true)
      end

      # Sets the specified string as the cookie for the Uri
      def using_cookie(cookie_string)
        clone(default_headers: { Wrest::H::Cookie => cookie_string })
      end
    end
  end
end
