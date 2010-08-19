module ResourceFull
  module CoreExtensions
    module Exception
      def to_xml(opts={})
        xml = opts[:builder] || Builder::XmlMarkup.new
    
        xml.errors {
          xml.error "#{self.class}: #{self.to_s}"
          xml.error self.backtrace
        }
      end
      
      def to_json(opts={})
        {"error" => {:text => "#{self.class}: #{self.to_s}",
                     :backtrace => self.backtrace}}.to_json
      end
    end
  end
end

class Exception
  include ResourceFull::CoreExtensions::Exception
end
