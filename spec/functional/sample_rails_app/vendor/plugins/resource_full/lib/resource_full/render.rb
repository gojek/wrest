module ResourceFull
  module Render
    include ResourceFull::Render::HTML
    include ResourceFull::Render::JSON
    include ResourceFull::Render::XML
    
    def self.included(controller)
      controller.rescue_from Exception, :with => :handle_generic_exception_with_correct_response_format
    end
    
    private
  
    CONFLICT_MESSAGE = if defined?(ActiveRecord::Errors) 
      if ([Rails::VERSION::MAJOR, Rails::VERSION::MINOR] <=> [2,1]) >= 0 # if the rails version is 2.1 or greater...Í
        (I18n.translate 'activerecord.errors.messages')[:taken]
      else
        ActiveRecord::Errors.default_error_messages[:taken]
      end
    else 
      "has already been taken"
    end

    def status_for(errors)
      if errors.any? { |message| message.include? CONFLICT_MESSAGE }
        :conflict
      else :unprocessable_entity end
    end
    
    def handle_generic_exception_with_correct_response_format(exception)
      if request.format.xml?
        if defined?(ExceptionNotifiable) && defined?(ExceptionNotifier) && self.is_a?(ExceptionNotifiable) && !(consider_all_requests_local || local_request?)
          deliverer = self.class.exception_data
           data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
           end
        
           ExceptionNotifier.deliver_exception_notification(exception, self,
             request, data)
        end
        logger.error exception.message + "\n" + exception.clean_backtrace.collect {|s| "\t#{s}\n"}.join
        render :xml => exception.to_xml, :status => :server_error
      elsif request.format.json?
        if defined?(ExceptionNotifiable) && defined?(ExceptionNotifier) && self.is_a?(ExceptionNotifiable) && !(consider_all_requests_local || local_request?)
          deliverer = self.class.exception_data
           data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
           end
        
           ExceptionNotifier.deliver_exception_notification(exception, self,
             request, data)
        end
        logger.error exception.message + "\n" + exception.clean_backtrace.collect {|s| "\t#{s}\n"}.join
        render :json => exception.to_json, :status => :server_error
      else
        raise exception
      end
    end
  end
end
