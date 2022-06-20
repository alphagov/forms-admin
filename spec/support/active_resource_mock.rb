class ActiveResourceMock
  def self.mock_resource(resource, methods)
    ActiveResource::HttpMock.respond_to do |mock|
      builder = MockBuilder.new(resource, mock)

      if methods.include?(:all)
        builder.all(methods[:all][:response], methods[:all][:status])
      end

      if methods.include?(:create)
        builder.create(methods[:create][:response], methods[:create][:status])
      end

      if methods.include?(:read)
        builder.read(methods[:read][:response], methods[:read][:status])
      end

      if methods.include?(:update)
        builder.update(methods[:update][:response], methods[:update][:status])
      end

      if methods.include?(:delete)
        builder.delete(methods[:delete][:response], methods[:delete][:status])
      end
    end
  end

  class MockBuilder
    def initialize(resource, mock)
      @resource = resource
      @mock = mock
    end

    def all(response, status)
      response = [] if response.nil?
      status = 200 if status.nil?
      request_path = @resource.class.collection_path(@resource.prefix_options)
      @mock.get request_path, {}, response.to_json, status
    end

    def create(response, status)
      response = {} if response.nil?
      status = 200 if status.nil?
      request_path = @resource.class.collection_path(@resource.prefix_options)
      @mock.post request_path, {}, response, status
    end

    def read(response, status)
      response = {} if response.nil?
      status = 200 if status.nil?
      request_path = @resource.class.element_path(@resource.id, @resource.prefix_options)
      @mock.get request_path, {}, response.to_json, status
    end

    def update(response, status)
      response = {} if response.nil?
      status = 200 if status.nil?
      request_path = @resource.class.element_path(@resource.id, @resource.prefix_options)
      @mock.put request_path, {}, response.to_json, status
    end

    def delete(response, status)
      response = {} if response.nil?
      status = 200 if status.nil?
      request_path = @resource.class.element_path(@resource.id, @resource.prefix_options)
      @mock.delete request_path, {}, response.to_json, status
    end

  private

    def http_mock(&block)
      ActiveResource::HttpMock.respond_to(&block)
    end
  end
end
