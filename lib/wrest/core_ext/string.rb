require "#{WREST_ROOT}/lib/wrest/core_ext/string/to_uri"

class String
  include Wrest::CoreExt::String::Conversions
end