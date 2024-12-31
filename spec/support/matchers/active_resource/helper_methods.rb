class HelperMethods
  def self.format_failure_message(resource, expected_request, _requests)
    msg = []
    msg << "Expected #{resource.class} to have been updated."
    msg << "Expected request:"
    msg << expected_request
    msg << "The following requests have been made:"
    msg << ActiveResource::HttpMock.requests.map(&:to_s)
    msg.join("\r\n")
  end
end
