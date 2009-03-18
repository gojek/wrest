module Wrest
  module CoreExt #:nodoc:
    module String #:nodoc:
      # Makes it easier to build other objects from a String
      module Conversions

        # Equivalent to Wrest::Uri.new(string)
        def to_uri
          Wrest::Uri.new(self)
        end
      end
    end
  end
end
