class Pages::QuestionForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text, :hint_text, :is_optional, :answer_type, :draft_question

  # TODO: We could lose these attributes once we have an Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  # TODO: Remove once we get rid of session storage
  attr_accessor :form_id, :page_id

  validates :draft_question, presence: true
  validates :hint_text, length: { maximum: 500 }

  def submit
    return false if invalid?

    draft_question.question_text = question_text
    draft_question.hint_text = hint_text
    draft_question.is_optional = is_optional
    draft_question.question_text = question_text
    draft_question.save!(validate: false)
  end
end
