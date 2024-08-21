class Page < ActiveResource::Base
  include QuestionTextValidation

  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  ANSWER_TYPES = %w[name organisation_name email phone_number national_insurance_number address date selection number text].freeze

  ANSWER_TYPES_WITHOUT_SETTINGS = %w[organisation_name email phone_number national_insurance_number number].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze

  belongs_to :form

  validates :hint_text, length: { maximum: 500 }

  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }
  before_validation :convert_boolean_fields

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

    put(direction)
  end

  def show_selection_options
    answer_settings.selection_options.map { |option| option.attributes[:name] }.join(", ")
  end

  def submit
    save!
  end

  def conditions
    routing_conditions.map { |routing_condition| Condition.new(routing_condition.attributes) }
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
        page.position != pages.length && page.conditions.empty?
    end
  end
end
