RSpec::Matchers.define :have_been_created do
  match do |resource|
    expected_request_path = resource.class.collection_path(resource.prefix_options)
    expected_request = ActiveResource::Request.new(:post, expected_request_path, resource.to_json)
    matched_request = ActiveResource::HttpMock.requests.find do |request|
      request.method == expected_request.method &&
        request.path == expected_request.path &&
        request.body == expected_request.body
    end

    !matched_request.nil?
  end

  failure_message do |resource|
    expected_request_path = resource.class.collection_path(resource.prefix_options)
    expected_request = ActiveResource::Request.new(:post, expected_request_path, resource.to_json)

    HelperMethods.format_failure_message(resource, expected_request, ActiveResource::HttpMock.requests)
  end
end
