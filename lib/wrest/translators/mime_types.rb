module Wrest
  module Translators
    MIME_TYPES = {
      'application/xml' => Wrest::Translators::Xml,
      'text/xml' => Wrest::Translators::Xml
    }
  end
end