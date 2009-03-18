# This client is targetted at Rails REST apps
# It is intended as a replacement for ActiveResource
class Wrest::Mappers::Resource::Base
  class << self
    def host=(host_url)
      self.class_eval "def self.host; '#{host_url.clone}';end"
    end
    
    def resource_path
      @resource_path ||= "/#{self.name.underscore.pluralize}"
    end
    
    def find(scope)
      case scope
      when :all then
        Wrest::Uri.new("#{host}#{resource_path}").get
      end
    end
  end
end
