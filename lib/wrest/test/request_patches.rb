class Wrest::Native::Request
  def invoke
    raise Wrest::Exceptions::RealRequestMadeInTestEnvironmet, 'A real HTTP request was made while running tests. Please avoid using live HTTP connections while testing and replace them with mocks.'
  end
end
