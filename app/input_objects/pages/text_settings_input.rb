class Pages::TextSettingsInput < BaseInput
  attr_accessor :input_type, :draft_question

  INPUT_TYPES = %w[single_line long_text].freeze

  validates :draft_question, presence: true
  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit
    return false if invalid?

    # Set the answer_settings hash
    answer_settings = {
      input_type:,
    }

    # Set answer_settings for the draft_question
    draft_question
      .assign_attributes({ answer_settings: })

    draft_question.save!(validate: false)
  end
end
