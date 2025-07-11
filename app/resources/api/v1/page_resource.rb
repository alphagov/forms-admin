class Api::V1::PageResource < ActiveResource::Base
  include QuestionTextValidation

  self.element_name = "page"
  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  belongs_to :form
  has_many :routing_conditions, class_name: "Api::V1::ConditionResource"

  validates :hint_text, length: { maximum: 500 }

  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }

  before_validation :convert_boolean_fields

  def database_attributes
    attributes
      .slice(*Page.attribute_names)
      .merge(prefix_options)
  end

  def has_next_page?
    attributes.include?("next_page") && !attributes["next_page"].nil?
  end

  def convert_boolean_fields
    self.is_optional = is_optional?
    self.is_repeatable = is_repeatable?
  end

  def is_optional?
    ActiveRecord::Type::Boolean.new.cast(@attributes["is_optional"]) || false
  end

  def is_repeatable?
    ActiveRecord::Type::Boolean.new.cast(@attributes["is_repeatable"]) || false
  end

  def move_page(direction)
    return false unless %i[up down].include? direction

    load_attributes_from_response(put(direction))
  end

  def show_selection_options
    answer_settings.selection_options.map { |option| option.attributes[:name] }.join(", ")
  end

  def conditions
    ActiveSupport::Deprecation.new.warn("Prefer #routing_conditions to #conditions")
    routing_conditions.map { |routing_condition| Api::V1::ConditionResource.new(routing_condition.attributes) }
  end

  def question_with_number
    "#{position}. #{question_text}"
  end

  def show_optional_suffix?
    is_optional? && answer_type != "selection"
  end

  def self.qualifying_route_pages(pages)
    pages.filter do |page|
      page.answer_type == "selection" && page.answer_settings.only_one_option == "true" &&
        page.position != pages.length
    end
  end
end
