class Pages::DateSettingsForm < BaseForm
  attr_accessor :input_type, :draft_question

  INPUT_TYPES = %w[date_of_birth other_date].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit
    return false if invalid?

    draft_question.answer_settings[:input_type] = input_type
    draft_question.save!(validate: false)
  end
end
