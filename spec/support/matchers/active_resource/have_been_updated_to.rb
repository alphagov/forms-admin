RSpec::Matchers.define :have_been_updated_to do |updated_resource|
  match do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    expected_request = ActiveResource::Request.new(:put, expected_request_path, updated_resource.to_json)
    matched_request = ActiveResource::HttpMock.requests.find do |request|
      request.method == expected_request.method &&
        request.path == expected_request.path &&
        JSON.parse(request.body) == JSON.parse(expected_request.body)
    end

    !matched_request.nil?
  end

  failure_message do |resource|
    expected_request_path = resource.class.element_path(resource.id, resource.prefix_options)
    expected_request = ActiveResource::Request.new(:put, expected_request_path, updated_resource.to_json)

    HelperMethods.format_failure_message(updated_resource, expected_request, ActiveResource::HttpMock.requests)
  end
end
