class Forms::TextSettingsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :input_type, :form, :page

  INPUT_TYPES = %w[single_line long_text].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit(session)
    return false if invalid?

    session[:page][:answer_settings] = { input_type: }
  end

  def assign_values_to_page(page)
    return false if invalid?

    page.answer_settings = { input_type: }
  end
end
