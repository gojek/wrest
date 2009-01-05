require "#{WREST_ROOT}/lib/core_ext/string/to_uri"

class String
  include CoreExt::String::Conversions
end