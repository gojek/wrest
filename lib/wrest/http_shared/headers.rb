#
# Header module.
#
# Provides access to headers in the mixed-into class as a hash-like
# object, except with case-insensitive keys.  Also provides
# methods for accessing commonly-used header values in a more
# convenient format.
#
# Sourced from Net::HTTP and then modified to be generic
module Wrest
  module HttpShared
    module Headers

      def initialize_http_header
        headers.each do |key, value|
          headers[key.downcase] = value.strip
        end
      end

      # Returns the header field corresponding to the case-insensitive key.
      # For example, a key of "Content-Type" might return "text/html"
      def [](key)
        headers[key] || headers[key.downcase]
      end

      # # Sets the header field corresponding to the case-insensitive key.
      # def []=(key, val)
      #   unless val
      #     headers.delete key.downcase
      #     return val
      #   end
      #   headers[key.downcase] = [val]
      # end
      #
      # # [Ruby 1.8.3]
      # # Adds header field instead of replace.
      # # Second argument +val+ must be a String.
      # # See also #[]=, #[] and #get_fields.
      # #
      # #   request.add_field 'X-My-Header', 'a'
      # #   p request['X-My-Header']              #=> "a"
      # #   p request.get_fields('X-My-Header')   #=> ["a"]
      # #   request.add_field 'X-My-Header', 'b'
      # #   p request['X-My-Header']              #=> "a, b"
      # #   p request.get_fields('X-My-Header')   #=> ["a", "b"]
      # #   request.add_field 'X-My-Header', 'c'
      # #   p request['X-My-Header']              #=> "a, b, c"
      # #   p request.get_fields('X-My-Header')   #=> ["a", "b", "c"]
      # #
      # def add_field(key, val)
      #   if headers.key?(key.downcase)
      #     headers[key.downcase].push val
      #   else
      #     headers[key.downcase] = [val]
      #   end
      # end
      #
      # # [Ruby 1.8.3]
      # # Returns an array of header field strings corresponding to the
      # # case-insensitive +key+.  This method allows you to get duplicated
      # # header fields without any processing.  See also #[].
      # #
      # #   p response.get_fields('Set-Cookie')
      # #     #=> ["session=al98axx; expires=Fri, 31-Dec-1999 23:58:23",
      # #          "query=rubyscript; expires=Fri, 31-Dec-1999 23:58:23"]
      # #   p response['Set-Cookie']
      # #     #=> "session=al98axx; expires=Fri, 31-Dec-1999 23:58:23, query=rubyscript; expires=Fri, 31-Dec-1999 23:58:23"
      # #
      # def get_fields(key)
      #   return nil unless headers[key.downcase]
      #   headers[key.downcase].dup
      # end
      #
      # # Returns the header field corresponding to the case-insensitive key.
      # # Returns the default value +args+, or the result of the block, or nil,
      # # if there's no header field named key.  See Hash#fetch
      # def fetch(key, *args, &block)   #:yield: +key+
      #   a = headers.fetch(key.downcase, *args, &block)
      #   a.join(', ')
      # end
      #
      # # Iterates for each header names and values.
      # def each_header   #:yield: +key+, +value+
      #   headers.each do |k,va|
      #     yield k, va.join(', ')
      #   end
      # end
      #
      # alias each each_header
      #
      # # Iterates for each header names.
      # def each_name(&block)   #:yield: +key+
      #   headers.each_key(&block)
      # end
      #
      # alias each_key each_name
      #
      # # Iterates for each capitalized header names.
      # def each_capitalized_name(&block)   #:yield: +key+
      #   headers.each_key do |k|
      #     yield capitalize(k)
      #   end
      # end
      #
      # # Iterates for each header values.
      # def each_value   #:yield: +value+
      #   headers.each_value do |va|
      #     yield va.join(', ')
      #   end
      # end
      #
      # # Removes a header field.
      # def delete(key)
      #   headers.delete(key.downcase)
      # end
      #
      # # true if +key+ header exists.
      # def key?(key)
      #   headers.key?(key.downcase)
      # end
      #
      # # Returns a Hash consist of header names and values.
      # def to_hash
      #   headers.dup
      # end
      #
      # # As for #each_header, except the keys are provided in capitalized form.
      # def each_capitalized
      #   headers.each do |k,v|
      #     yield capitalize(k), v.join(', ')
      #   end
      # end
      #
      # alias canonical_each each_capitalized
      #
      # def capitalize(name)
      #   name.split(/-/).map {|s| s.capitalize }.join('-')
      # end
      # private :capitalize
      #
      # # Returns an Array of Range objects which represents Range: header field,
      # # or +nil+ if there is no such header.
      # def range
      #   return nil unless headers['range']
      #   self['Range'].split(/,/).map {|spec|
      #     m = /bytes\s*=\s*(\d+)?\s*-\s*(\d+)?/i.match(spec) or
      #     raise HTTPHeaderSyntaxError, "wrong Range: #{spec}"
      #     d1 = m[1].to_i
      #     d2 = m[2].to_i
      #     if    m[1] and m[2] then  d1..d2
      #     elsif m[1]          then  d1..-1
      #     elsif          m[2] then -d2..-1
      #     else
      #       raise HTTPHeaderSyntaxError, 'range is not specified'
      #     end
      #   }
      # end
      #
      # # Set Range: header from Range (arg r) or beginning index and
      # # length from it (arg idx&len).
      # #
      # #   req.range = (0..1023)
      # #   req.set_range 0, 1023
      # #
      # def set_range(r, e = nil)
      #   unless r
      #     headers.delete 'range'
      #     return r
      #   end
      #   r = (r...r+e) if e
      #   case r
      #   when Numeric
      #     n = r.to_i
      #     rangestr = (n > 0 ? "0-#{n-1}" : "-#{-n}")
      #   when Range
      #     first = r.first
      #     last = r.last
      #     last -= 1 if r.exclude_end?
      #     if last == -1
      #       rangestr = (first > 0 ? "#{first}-" : "-#{-first}")
      #     else
      #       raise HTTPHeaderSyntaxError, 'range.first is negative' if first < 0
      #       raise HTTPHeaderSyntaxError, 'range.last is negative' if last < 0
      #       raise HTTPHeaderSyntaxError, 'must be .first < .last' if first > last
      #       rangestr = "#{first}-#{last}"
      #     end
      #   else
      #     raise TypeError, 'Range/Integer is required'
      #   end
      #   headers['range'] = ["bytes=#{rangestr}"]
      #   r
      # end
      #
      # alias range= set_range
      #
      # # Returns an Integer object which represents the Content-Length: header field
      # # or +nil+ if that field is not provided.
      # def content_length
      #   return nil unless key?('Content-Length')
      #   len = self['Content-Length'].slice(/\d+/) or
      #   raise HTTPHeaderSyntaxError, 'wrong Content-Length format'
      #   len.to_i
      # end
      #
      # def content_length=(len)
      #   unless len
      #     headers.delete 'content-length'
      #     return nil
      #   end
      #   headers['content-length'] = [len.to_i.to_s]
      # end
      #
      # # Returns "true" if the "transfer-encoding" header is present and
      # # set to "chunked".  This is an HTTP/1.1 feature, allowing the
      # # the content to be sent in "chunks" without at the outset
      # # stating the entire content length.
      # def chunked?
      #   return false unless headers['transfer-encoding']
      #   field = self['Transfer-Encoding']
      #   (/(?:\A|[^\-\w])chunked(?![\-\w])/i =~ field) ? true : false
      # end
      #
      # # Returns a Range object which represents Content-Range: header field.
      # # This indicates, for a partial entity body, where this fragment
      # # fits inside the full entity body, as range of byte offsets.
      # def content_range
      #   return nil unless headers['content-range']
      #   m = %r<bytes\s+(\d+)-(\d+)/(\d+|\*)>i.match(self['Content-Range']) or
      #   raise HTTPHeaderSyntaxError, 'wrong Content-Range format'
      #   m[1].to_i .. m[2].to_i + 1
      # end
      #
      # # The length of the range represented in Content-Range: header.
      # def range_length
      #   r = content_range() or return nil
      #   r.end - r.begin
      # end
      #
      # # Returns a content type string such as "text/html".
      # # This method returns nil if Content-Type: header field does not exist.
      # def content_type
      #   return nil unless main_type()
      #   if sub_type()
      #     "#{main_type()}/#{sub_type()}"
      #   else
      #     main_type()
      #   end
      # end
      #
      # # Returns a content type string such as "text".
      # # This method returns nil if Content-Type: header field does not exist.
      # def main_type
      #   return nil unless headers['content-type']
      #   self['Content-Type'].split(';').first.to_s.split('/')[0].to_s.strip
      # end
      #
      # # Returns a content type string such as "html".
      # # This method returns nil if Content-Type: header field does not exist
      # # or sub-type is not given (e.g. "Content-Type: text").
      # def sub_type
      #   return nil unless headers['content-type']
      #   main, sub = *self['Content-Type'].split(';').first.to_s.split('/')
      #   return nil unless sub
      #   sub.strip
      # end
      #
      # # Returns content type parameters as a Hash as like
      # # {"charset" => "iso-2022-jp"}.
      # def type_params
      #   result = {}
      #   list = self['Content-Type'].to_s.split(';')
      #   list.shift
      #   list.each do |param|
      #     k, v = *param.split('=', 2)
      #     result[k.strip] = v.strip
      #   end
      #   result
      # end
      #
      # # Set Content-Type: header field by +type+ and +params+.
      # # +type+ must be a String, +params+ must be a Hash.
      # def set_content_type(type, params = {})
      #   headers['content-type'] = [type + params.map{|k,v|"; #{k}=#{v}"}.join('')]
      # end
      #
      # alias content_type= set_content_type
      #
      # # Set header fields and a body from HTML form data.
      # # +params+ should be a Hash containing HTML form data.
      # # Optional argument +sep+ means data record separator.
      # #
      # # This method also set Content-Type: header field to
      # # application/x-www-form-urlencoded.
      # #
      # # Example:
      # #    http.form_data = {"q" => "ruby", "lang" => "en"}
      # #    http.form_data = {"q" => ["ruby", "perl"], "lang" => "en"}
      # #    http.set_form_data({"q" => "ruby", "lang" => "en"}, ';')
      # #
      # def set_form_data(params, sep = '&')
      #   self.body = params.map {|k, v| encode_kvpair(k, v) }.flatten.join(sep)
      #   self.content_type = 'application/x-www-form-urlencoded'
      # end
      #
      # alias form_data= set_form_data
      #
      # def encode_kvpair(k, vs)
      #   Array(vs).map {|v| "#{urlencode(k)}=#{urlencode(v.to_s)}" }
      # end
      # private :encode_kvpair
      #
      # def urlencode(str)
      #   str.dup.force_encoding('ASCII-8BIT').gsub(/[^a-zA-Z0-9_\.\-]/){'%%%02x' % $&.ord}
      # end
      # private :urlencode
      #
      # # Set the Authorization: header for "Basic" authorization.
      # def basic_auth(account, password)
      #   headers['authorization'] = [basic_encode(account, password)]
      # end
      #
      # # Set Proxy-Authorization: header for "Basic" authorization.
      # def proxy_basic_auth(account, password)
      #   headers['proxy-authorization'] = [basic_encode(account, password)]
      # end
      #
      # def basic_encode(account, password)
      #   'Basic ' + ["#{account}:#{password}"].pack('m').delete("\r\n")
      # end
      # private :basic_encode
      #
      # def connection_close?
      #   tokens(headers['connection']).include?('close') or
      #   tokens(headers['proxy-connection']).include?('close')
      # end
      #
      # def connection_keep_alive?
      #   tokens(headers['connection']).include?('keep-alive') or
      #   tokens(headers['proxy-connection']).include?('keep-alive')
      # end
      #
      # def tokens(vals)
      #   return [] unless vals
      #   vals.map {|v| v.split(',') }.flatten\
      #   .reject {|str| str.strip.empty? }\
      #   .map {|tok| tok.strip.downcase }
      # end
    end
  end
end
