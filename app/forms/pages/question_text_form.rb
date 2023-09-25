class Pages::QuestionTextForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text, :draft_question

  def submit
    return false if invalid?

    draft_question.question_text = question_text
    draft_question.save!
  end
end
