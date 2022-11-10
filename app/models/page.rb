class Page < ActiveResource::Base
  self.site = (ENV["API_BASE"]).to_s
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false
  headers["X-API-Token"] = ENV["API_KEY"]

  attr_accessor :session

  ANSWER_TYPES = %w[single_line number address date email national_insurance_number phone_number long_text].freeze

  belongs_to :form
  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }
  before_validation :convert_is_optional_to_boolean

  after_save :clear_session, if: -> (obj) { obj.session.present? }

  def has_next_page?
    attributes.include?("next_page") && !attributes["next_page"].nil?
  end

  def number(form)
    # If this page is in form, return the position, else it must be new so
    # return the number if it was inserted at the end
    index = form.pages.index(self)
    (index.nil? ? form.pages.length : index) + 1
  end

  def convert_is_optional_to_boolean
    self.is_optional = is_optional_value
  end
  def move_page(direction)
    return false unless %i[up down].include? direction

    put(direction)
  end
  def submit
    save!
  end

private

  def is_optional_value
    return true if is_optional == "true"
  end

  def clear_session
    session.delete(:page)
  end
end
