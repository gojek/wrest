require 'rspec/matchers/have'

RSpec::Matchers.define :have do |expected|
  chain :callbacks_for do |key|
    @key = key
  end

  match do |actual|
    @failure_message = ""
    pass = true
    unless actual.key?(@key)
      @failure_message += "no key #{@key} found"
      pass = false
    end

    if pass
      unless (actual[@key].size == expected) 
        @failure_message += "expected #{expected} callbacks but got #{actual[@key].size}. "
        pass = false
      end

      actual[@key].each do |callback|
        unless callback.is_a?(Proc)
          @failure_message += "expected callback to be an instance of Proc but got #{callback.class}. "
          pass = false
          break
        end
        unless callback.arity == 1
          @failure_message += "expected callback to have arity 1 but got #{callback.arity}."
          pass = false
          break
        end
      end
    end
    pass
  end

  failure_message_for_should do |actual|
    @failure_message
  end
end


