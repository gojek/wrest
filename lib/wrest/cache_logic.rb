module Wrest
  class CacheLogic

    def initialize(get, cache_store)
      @get         = get
      @cache_store = cache_store
    end

    def get
      return nil unless @cache_store

      cached_response = cache_store[self.hash]
      return nil unless cached_response

      if cached_response.expired?
        if cached_response.can_be_validated?
          get_validated_response_for(cached_response)
        else
          nil
        end
      else
        cached_response
      end
    end


  end
end
