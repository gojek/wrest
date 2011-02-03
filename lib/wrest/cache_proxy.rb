module Wrest

  class CacheProxy
    class << self
      def new(get, cache_store)
        if cache_store
          DefaultCacheProxy.new(get, cache_store)
        else
          NullCacheProxy.new(get)
        end
      end
    end

    class NullCacheProxy
      def initialize(get)
        @get = get
      end
      def get
        @get.invoke_without_cache_check
      end
    end

    class DefaultCacheProxy
      HOP_BY_HOP_HEADERS = ["connection",
                           "keep-alive",
                           "proxy-authenticate",
                           "proxy-authorization",
                           "te",
                           "trailers",
                           "transfer-encoding",
                           "upgrade"]

      def initialize(get, cache_store)
        @get         = get
        @cache_store = cache_store
      end

      def log_cached_response
          Wrest.logger.debug "<*> (GET #{@get.hash}) #{@get.uri.protocol}://#{@get.uri.host}:#{@get.uri.port}#{@get.http_request.path}"
      end
      
      def get
        cached_response = @cache_store[@get.hash]
        return get_fresh_response if cached_response.nil?

        if cached_response.expired?
          if cached_response.can_be_validated?
            get_validated_response_for(cached_response)
          else
            get_fresh_response
          end
        else
          log_cached_response
          cached_response
        end
      end

      def update_cache_headers_for(cached_response, new_response)
        # RFC 2616 13.5.3 (Combining Headers)
        cached_response.headers.merge!(new_response.headers.select {|key, value| not (HOP_BY_HOP_HEADERS.include? key.downcase)})
      end

      def cache(response)
        @cache_store[@get.hash] = response.clone if response && response.cacheable?
      end

      #:nodoc:
      def get_fresh_response
        @cache_store.delete @get.hash

        response = @get.invoke_without_cache_check

        cache(response)

        response
      end

      #:nodoc:
      def get_validated_response_for(cached_response)
        new_response = send_validation_request_for(cached_response)
        if new_response.code == "304"
          update_cache_headers_for(cached_response, new_response)
          log_cached_response
          cached_response
        else
          cache(new_response)
          new_response
        end
      end

      #:nodoc:
      # Send a cache-validation request to the server. This would be the actual Get request with extra cache-validation headers.
      # If a 304 (Not Modified) is received, Wrest would use the cached_response itself. Otherwise the new response is cached and used.
      def send_validation_request_for(cached_response)
        last_modified            = cached_response.last_modified
        etag                     = cached_response.headers["etag"]

        cache_validation_headers = {}
        cache_validation_headers["if-modified-since"] = last_modified unless last_modified.nil?
        cache_validation_headers["if-none-match"] = etag unless etag.nil?

        new_request = @get.build_request_without_cache_store(cache_validation_headers)

        new_request.invoke
      end
    end
  end
end