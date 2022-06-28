RSpec::Matchers.define :have_been_deleted do
  match do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    expected_request = ActiveResource::Request.new(:delete, expected_request_path)

    matched_request = ActiveResource::HttpMock.requests.find do |request|
      request.method == expected_request.method &&
        request.path == expected_request.path
    end

    !matched_request.nil?
  end

  failure_message do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    expected_request = ActiveResource::Request.new(:delete, expected_request_path)

    HelperMethods.format_failure_message(resource, expected_request, ActiveResource::HttpMock.requests)
  end
end
