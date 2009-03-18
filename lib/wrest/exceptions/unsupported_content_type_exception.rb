module Wrest
  # Raised when a translator for an unregisterd response content type
  # is requested. See Translators.
  class UnsupportedContentTypeException < StandardError
  end
end
