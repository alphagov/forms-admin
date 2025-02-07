module FormsApiDeprecations
  class << self
    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("v2", "GOV.UK Forms API")
    end

    def warn_if_forms_model_path(path, message, callstack = nil)
      callstack ||= caller_locations(2)

      if forms_model_path?(path)
        deprecator.warn(message, callstack)
      end
    end

    def warn_unless_called_from_repository(message, callstack)
      unless called_from_repository?(callstack)
        deprecator.warn(message, callstack)
      end
    end

    def called_from_repository?(callstack)
      callstack.any? { |location| location.path.match? %r{app/services/\w+_repository.rb$} }
    end

    def forms_model_path?(path)
      path.starts_with? "/api/v1/forms"
    end
  end
end

Rails.application.deprecators[:forms_api] ||= FormsApiDeprecations.deprecator

if Rails.env.local?
  module ActiveResourceRequestMonkeypatch
    def request(...)
      FormsApiDeprecations.warn_unless_called_from_repository("ActiveResource request made outside repository", caller_locations(3))
      super
    end
  end

  ActiveResource::Connection.prepend(ActiveResourceRequestMonkeypatch)

  module ActiveResourceHttpMockMonkeypatch
    %i[post patch put get delete head].each do |method|
      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(path, ...)
          FormsApiDeprecations.warn_if_forms_model_path(path, "Prefer to stub forms models by mocking the repository service instead of using HttpMock")

          super
        end
      RUBY
    end
  end

  ActiveResource::HttpMock::Responder.prepend(ActiveResourceHttpMockMonkeypatch)

  module FormResourcePagesMonkeypatch
    def pages(...)
      FormsApiDeprecations.warn_unless_called_from_repository("Form#pages request made outside repository", caller_locations(1))
      super
    end
  end

  Rails.application.config.after_initialize do
    Api::V1::FormResource.prepend(FormResourcePagesMonkeypatch)
  end
end
