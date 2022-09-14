# frozen_string_literal: true

module Wrest
  module Utils
    module_function

    # https://github.com/rails/rails/commit/2a371368c91789a4d689d6a84eb20b238c37678a
    # A string is blank if it's empty or contains whitespaces only:
    #
    #   "".blank?                 # => true
    #   "   ".blank?              # => true
    #   "　".blank?               # => true
    #   " something here ".blank? # => false
    #
    def string_blank?(string)
      string !~ /[^[:space:]]/
    end

    # https://github.com/rails/rails/commit/69b550fc88f0e155ab997476e576142a2dbec324
    # Tries to find a constant with the name specified in the argument string.
    #
    #   constantize('Module')   # => Module
    #   constantize('Foo::Bar') # => Foo::Bar
    #
    # The name is assumed to be the one of a top-level constant, no matter
    # whether it starts with "::" or not. No lexical context is taken into
    # account:
    #
    #   C = 'outside'
    #   module M
    #     C = 'inside'
    #     C                # => 'inside'
    #     constantize('C') # => 'outside', same as ::C
    #   end
    #
    # NameError is raised when the name is not in CamelCase or the constant is
    # unknown.
    def string_constantize(camel_cased_word)
      Object.const_get(camel_cased_word)
    end

    # https://github.com/rails/rails/commit/69b550fc88f0e155ab997476e576142a2dbec324
    # Removes the module part from the expression in the string.
    #
    #   demodulize('ActiveSupport::Inflector::Inflections') # => "Inflections"
    #   demodulize('Inflections')                           # => "Inflections"
    #   demodulize('::Inflections')                         # => "Inflections"
    #   demodulize('')                                      # => ""
    #
    def string_demodulize(path)
      path = path.to_s
      if (i = path.rindex('::'))
        path[(i + 2)..]
      else
        path
      end
    end

    # https://github.com/rails/rails/commit/69b550fc88f0e155ab997476e576142a2dbec324
    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    #   underscore('ActiveModel')         # => "active_model"
    #   underscore('ActiveModel::Errors') # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of
    # #camelize, though there are cases where that does not hold:
    #
    #   camelize(underscore('SSLError'))  # => "SslError"
    def string_underscore(camel_cased_word)
      return camel_cased_word.to_s unless /[A-Z-]|::/.match?(camel_cased_word)

      word = camel_cased_word.to_s.gsub('::', '/')
      word.gsub!(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { (Regexp.last_match(1) || Regexp.last_match(2)) << '_' }
      word.tr!('-', '_')
      word.downcase!
      word
    end

    # https://github.com/rails/rails/commit/a0d7247d1509762283c61182ad82c2eed8d54757
    # Returns a string representation of the receiver suitable for use as a URL
    # query string:
    #
    #   {:name => 'David', :nationality => 'Danish'}.to_param
    #   # => "name=David&nationality=Danish"
    #
    # The string pairs "key=value" that conform the query string
    # are sorted lexicographically in ascending order.
    #
    def hash_to_param(hash)
      hash.collect do |key, value|
        object_to_query(key, value)
      end.sort * '&'
    end

    # https://github.com/rails/rails/commit/52b71c01fd3c8a87152f55129a8cb3234190734a
    #
    # Converts an object into a string suitable for use as a URL query string, using the given <tt>key</tt> as the
    # param name.
    def object_to_query(key, object)
      "#{CGI.escape(key.to_s)}=#{CGI.escape(object.to_s)}"
    end

    # https://github.com/rails/rails/commit/18707ab17fa492eb25ad2e8f9818a320dc20b823
    # An object is blank if it's false, empty, or a whitespace string.
    # For example, +nil+, '', '   ', [], {}, and +false+ are all blank.
    #
    # This simplifies
    #
    #   !address || address.empty?
    #
    # to
    #
    #   address.blank?
    #
    # @return [true, false]
    def object_blank?(object)
      object.respond_to?(:empty?) ? !!object.empty? : !object
    end

    # https://github.com/rails/rails/commit/6372d23616b13c62c7a12efa89f958b334dd66ae
    # Converts self to an integer number of seconds since the Unix epoch.
    def datetime_to_i(datetime)
      seconds_per_day = 86_400
      ((datetime - ::DateTime.civil(1970)) * seconds_per_day).to_i
    end
  end
end
