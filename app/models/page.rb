class Page < ActiveResource::Base
  include QuestionTextValidation

  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  ANSWER_TYPES = %w[name organisation_name email phone_number national_insurance_number address date selection number text].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze

  belongs_to :form

  validates :hint_text, length: { maximum: 500 }

  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }
  before_validation :convert_is_optional_to_boolean

  def has_next_page?
    attributes.include?("next_page") && !attributes["next_page"].nil?
  end

  def convert_is_optional_to_boolean
    self.is_optional = is_optional_value
  end

  def is_optional?
    is_optional_value || is_optional == true
  end

  def move_page(direction)
    return false unless %i[up down].include? direction

    put(direction)
  end

  def show_selection_options
    answer_settings.selection_options.map(&:name).join(", ")
  end

  def submit
    save!
  end

  def load_from_session(session, keys)
    keys.each do |key|
      self.load("#{key}": session.dig(:page, key.to_sym) || send(key.to_sym))
    end
    self
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

private

  def is_optional_value
    return true if is_optional == "true"
  end
end
