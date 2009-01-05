module Kernel
  def require_with_wrest_root(string)
    begin
      begin
        require_without_wrest_root(string) 
      rescue LoadError => e
        # Wrest.logger.debug "#{e}: require '#{string}' invoked from #{caller[0]} failed, trying within #{WREST_ROOT}/lib/wrest..."
        require_without_wrest_root("#{WREST_ROOT}/lib/wrest/#{string}")
      end  
    rescue Exception => e
      Wrest.logger.info "#{e}: require '#{string}' invoked from #{caller[0]} failed!"
      raise e
    end  
  end
  alias_method_chain :require, :wrest_root
end