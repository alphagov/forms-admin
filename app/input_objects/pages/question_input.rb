class Pages::QuestionInput < BaseInput
  include QuestionTextValidation

  attr_accessor :question_text, :hint_text, :is_optional, :answer_type, :draft_question

  # TODO: We could lose these attributes once we have an Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  validates :draft_question, presence: true
  validates :hint_text, length: { maximum: 500 }

  def submit
    return false if invalid?

    draft_question.assign_attributes(
      question_text:,
      hint_text:,
      is_optional:,
    )

    draft_question.save!(validate: false)
  end
end
