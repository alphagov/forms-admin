class Pages::TextSettingsForm < BaseForm
  attr_accessor :input_type, :form, :page

  INPUT_TYPES = %w[single_line long_text].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type: }
  end
end
