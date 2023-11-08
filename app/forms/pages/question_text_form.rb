class Pages::QuestionTextForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text, :draft_question

  validates :draft_question, presence: true

  def submit
    return false if invalid?

    # Set question_text for the draft_question
    draft_question
      .assign_attributes(question_text:)

    draft_question.save!(validate: false)
  end
end
