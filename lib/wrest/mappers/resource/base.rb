class Wrest::Mappers::Resource::Base
  class << self
    def host=(host_url)
      self.class.class_eval "def host; '#{host_url.clone}';end"
    end
  end
end
