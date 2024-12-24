module FormsApiDeprecations
  class << self
    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("v2", "GOV.UK Forms API")
    end

    def warn_unless_called_from_repository(message, callstack)
      unless called_from_repository?(callstack)
        deprecator.warn(message, callstack)
      end
    end

    def called_from_repository?(callstack)
      callstack.any? { |location| location.path.match? %r{app/services/\w+_repository.rb$} }
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
end
