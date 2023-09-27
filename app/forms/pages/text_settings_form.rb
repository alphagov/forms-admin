class Pages::TextSettingsForm < BaseForm
  attr_accessor :input_type, :draft_question

  INPUT_TYPES = %w[single_line long_text].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit
    return false if invalid?

    draft_question.answer_settings[:input_type] = input_type
    draft_question.save!(validate: false)
  end
end
