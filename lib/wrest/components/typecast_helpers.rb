module Wrest::Components #:nodoc:
  # Provides helper methods which build lambdas
  # to cast strings to specific types.
  module TypecastHelpers
    def as_base64Binary
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['base64Binary']
    end

    def as_boolean
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['boolean']
    end

    def as_decimal
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['decimal']
    end

    def as_date
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['date']
    end

    def as_datetime
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['datetime']
    end

    def as_float
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['float']
    end

    def as_integer
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['integer']
    end

    def as_symbol
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['symbol']
    end

    def as_yaml
      ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['yaml']
    end
  end
end
