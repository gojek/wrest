
require 'translators/xml'
require 'translators/mime_types'

module Wrest
  module Translators
    def self.build(response)
      content_type = response.content_type
      mime_type = MIME_TYPES[content_type] ? mime_type.new(response) : (raise UnsupportedMimeTypeException.new("Unsupported content type #{content_type}"))
    end
  end
end
