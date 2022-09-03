# frozen_string_literal: true

require 'wrest/core_ext/string/conversions'

class String # :nodoc:
  include Wrest::CoreExt::String::Conversions unless Wrest.const_defined?('NoStringExtensions')
end
