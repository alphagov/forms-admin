class Page < ActiveResource::Base
  self.site = (ENV["API_BASE"]).to_s
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = ENV["API_KEY"]

  ANSWER_TYPES = %w[single_line number address date email national_insurance_number phone_number long_text selection organisation_name text].freeze

  COMPLEX_ANSWER_TYPES = %w[selection text date address].freeze

  belongs_to :form
  validates :question_text, presence: true
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
      self.load(key => session.dig(:page, key) || send(key.to_sym))
    end
  end

private

  def is_optional_value
    return true if is_optional == "true"
  end
end
