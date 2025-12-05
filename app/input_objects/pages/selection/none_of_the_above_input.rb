class Pages::Selection::NoneOfTheAboveInput < BaseInput
  IS_OPTIONAL_OPTIONS = %w[true false].freeze

  attr_accessor :question_text, :is_optional, :draft_question

  validates :question_text, presence: true, length: { maximum: 250 }
  validates :is_optional, inclusion: { in: IS_OPTIONAL_OPTIONS }

  def answer_settings
    draft_question.answer_settings.merge(
      none_of_the_above_question: {
        question_text:,
        is_optional:,
      },
    )
  end

  def submit
    return false if invalid?

    draft_question.assign_attributes(answer_settings:)
    draft_question.save!(validate: false)
  end

  def is_optional_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end
end
