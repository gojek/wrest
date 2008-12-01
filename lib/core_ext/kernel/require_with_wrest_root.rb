module Kernel
  def require_with_wrest_root(string)
    begin
      begin
        require_without_wrest_root(string) 
      rescue LoadError
        require_without_wrest_root("#{WREST_ROOT}/lib/wrest/#{string}")
      end  
    rescue Exception => e
      puts "#{e}: require '#{string}' invoked from #{caller[0]} failed!"
    end  
  end
  alias_method_chain :require, :wrest_root
end