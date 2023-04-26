class Condition < ActiveResource::Base
  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/pages/:page_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  belongs_to :page

  def has_errors?
    # TODO: remove defined check once custom errors are in API
    defined?(validation_errors) && validation_errors.any?
  end

  def errors_include(error_name)
    has_errors? && validation_errors.map(&:name)&.include?(error_name)
  end
end
