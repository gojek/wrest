module Wrest
  module Exceptions #:nodoc:
    # Raised when a base method that should be overriden
    # is invoked on a subclass that has not implemented it.
    class MethodNotOverridden < StandardError
    end

    # Raised when a translator for an unregisterd response content type
    # is requested. See Translators.
    class UnsupportedContentType < StandardError
    end

    # Raised when a request auto redirects more times than are allowed
    # by its follow_redirects_limit. See Wrest::Http::Redirection.
    class AutoRedirectLimitExceeded < StandardError
    end

    # Raised when a request is made when either RAILS_ENV or
    # ENV['RAILS_ENV'] is set to 'test', which is the case when
    # running tests/specs in a Rails application.
    #
    # See wrest/test/request_patches.
    class RealRequestMadeInTestEnvironmet < StandardError
    end

    # Raised when a request times out
    class Timeout < StandardError
    end
    
    class UnsupportedHttpVerb < StandardError
    end
  end
end
