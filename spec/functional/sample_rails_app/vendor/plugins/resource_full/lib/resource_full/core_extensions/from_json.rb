module ResourceFull
  module CoreExtensions
    module Hash
      def from_json(json)
        ActiveSupport::JSON.decode json
      end
    end
  end
end

class Hash
  class << self
    include ResourceFull::CoreExtensions::Hash
  end
end
