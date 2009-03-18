require 'translators/xml'
require 'translators/json'
require 'translators/content_types'

module Wrest
  # Contains strategies/lambdas which know how to deserialise
  # different content types.
  module Translators
    # Loads the appropriate desirialisation strategy based on
    # the content type
    def self.load(content_type)
      translator = CONTENT_TYPES[content_type]
      translator || (raise UnsupportedContentTypeException.new("Unsupported content type #{content_type}"))
    end
  end
end
