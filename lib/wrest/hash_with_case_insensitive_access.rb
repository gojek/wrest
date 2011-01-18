module Wrest

  # A hash with case-insensitive key access.
  #
  #   hash = Wrest::HashWithCaseInsensitiveAccess.new 'Abcd' => 1, 'xyz' => 2
  #
  #   hash['abcd']  #=> 1
  #   hash['aBCd'] #=> 1
  #
  class HashWithCaseInsensitiveAccess < ::Hash #:nodoc:

    def initialize(hash={})
      super()
      hash.each do |key, value|
        self[convert_key(key)] = value
      end
    end
    def [](key)
      super(convert_key(key))
    end

    def []=(key, value)
      super(convert_key(key), value)
    end

    def delete(key)
      super(convert_key(key))
    end

    def values_at(*indices)
      indices.collect { |key| self[convert_key(key)] }
    end

    def merge(other)
      dup.merge!(other)
    end

    def merge!(other)
      other.each do |key, value|
        self[convert_key(key)] = value
      end
      self
    end

    protected

      def convert_key(key)
        key.is_a?(String) ? key.downcase : key
      end

  end
end
