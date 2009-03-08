require 'translators/xml'
require 'translators/json'
require 'translators/content_types'

module Wrest
  module Translators
    def self.load(content_type)
      translator = CONTENT_TYPES[content_type]
      translator || (raise UnsupportedContentTypeException.new("Unsupported content type #{content_type}"))
    end
  end
end
