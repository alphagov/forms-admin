class Forms::DateSettingsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :input_type, :form, :page

  INPUT_TYPES = %w[date_of_birth other_date].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type: }
  end
end
