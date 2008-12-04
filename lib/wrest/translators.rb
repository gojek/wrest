
require 'translators/xml'
require 'translators/mime_types'

module Wrest
  module Translators
    def self.build(response)
      MIME_TYPES[response.content_type].new(response)
    end
  end
end
