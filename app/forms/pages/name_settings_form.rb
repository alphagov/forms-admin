class Pages::NameSettingsForm < BaseForm
  attr_accessor :input_type, :title_needed

  INPUT_TYPES = %w[full_name first_and_last_name first_middle_and_last_name].freeze
  TITLE_NEEDED = %w[true false].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }
  validates :title_needed, presence: true, inclusion: { in: TITLE_NEEDED }

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type:, title_needed: }
  end
end
