RSpec::Matchers.define :have_been_updated do
  match do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    matched_request = ActiveResource::HttpMock.requests.find do |request|
      request.method == :put &&
        request.path == expected_request_path
    end

    !matched_request.nil?
  end

  failure_message do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    expected_request = ActiveResource::Request.new(:put, expected_request_path)

    HelperMethods.format_failure_message(resource, expected_request, ActiveResource::HttpMock.requests)
  end

  failure_message_when_negated do |resource|
    msg = []
    msg << "Expected #{resource.class} with ID #{resource.id} not to have been updated, but found a request to update it."
    msg << "The following requests have been made:"
    msg << ActiveResource::HttpMock.requests.to_s
    msg.join("\r\n")
  end
end
