class Pages::QuestionTextForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text, :draft_question

  validates :draft_question, presence: true

  def submit(session)
    return false if invalid?

    # Set question_text for the draft_question
    draft_question
      .assign_attributes(question_text:)

    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = {} if session[:page].blank?
    session[:page][:question_text] = question_text
  end
end
