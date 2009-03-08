module Wrest
  module Translators
    CONTENT_TYPES = {
      'application/xml' => Wrest::Translators::Xml,
      'text/xml' => Wrest::Translators::Xml,
      'text/javascript' => Wrest::Translators::Json
    }
  end
end