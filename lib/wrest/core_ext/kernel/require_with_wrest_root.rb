module Kernel
  # Does a normal require, followed by a
  # require which prefixes the location of
  # the wrest source.
  def require_with_wrest_root(string)
    begin
      begin
        # Wrest.logger.debug "requiring '#{string}' invoked from #{caller[0]} ..."
        require_without_wrest_root(string)
      rescue LoadError => e
        with_root = "#{WREST_ROOT}/lib/wrest/#{string}"
        # Wrest.logger.warn "#{e}: require '#{string}' invoked from #{caller[0]} failed, trying with #{with_root} ..."
        require_without_wrest_root(with_root)
      end
    rescue Exception => e
      Wrest.logger.error "#{e}: require '#{string}' invoked from #{caller[0]} failed!"
      raise e
    end
  end
  alias_method_chain :require, :wrest_root
end
