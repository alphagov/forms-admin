class Pages::DateSettingsForm < BaseForm
  attr_accessor :input_type

  INPUT_TYPES = %w[date_of_birth other_date].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type: }
  end
end
