class Pages::TypeOfAnswerForm < BaseForm
  attr_accessor :answer_type, :draft_question

  validates :draft_question, presence: true
  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }

  def submit(session)
    return false if invalid?

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = { answer_type:, answer_settings: nil }

    draft_question.answer_type = answer_type
    draft_question.answer_settings = nil
    draft_question.save!(validate: false)
  end
end
