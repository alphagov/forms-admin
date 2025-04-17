class Api::V1::ConditionResource < ActiveResource::Base
  self.element_name = "condition"
  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/pages/:page_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  belongs_to :page

  def errors_with_fields
    error_fields = {
      answer_value_doesnt_exist: :answer_value,
      goto_page_doesnt_exist: :goto_page_id,
      cannot_have_goto_page_before_routing_page: :goto_page_id,
      cannot_route_to_next_page: :goto_page_id,
    }
    validation_errors.map do |error|
      { name: error.name, field: error_fields[error.name.to_sym] || :answer_value }
    end
  end

  def secondary_skip?
    answer_value.blank? && check_page_id != routing_page_id
  end

  def exit_page?
    attributes.include?("exit_page_markdown") && !attributes["exit_page_markdown"].nil?
  end
end
