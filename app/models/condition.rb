class Condition < ActiveResource::Base
  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/pages/:page_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  belongs_to :page

  def errors_with_fields
    error_fields = { "goto_page_doesnt_exist" => :goto_page_id, "answer_value_doesnt_exist" => :answer_value }
    validation_errors.map { |error| { name: error.name, field: error_fields[error.name] } }
  end

  def has_errors_for_field?(field)
    errors_with_fields.filter { |error| error[:field] == field }.any?
  end

  def has_errors?
    validation_errors.any?
  end

  def errors_include?(error_name)
    has_errors? && validation_errors.map(&:name).include?(error_name)
  end
end
