class HelperMethods
  def self.format_failure_message(resource, expected_request, _requests)
    msg = []
    msg << "Expected #{resource.class} to have been updated."
    msg << "Expected #{expected_request} to have been made."
    msg << "The following requests have been made:"
    msg << ActiveResource::HttpMock.requests.to_s
    msg.join("\r\n")
  end
end
