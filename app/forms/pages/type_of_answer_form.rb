class Pages::TypeOfAnswerForm < BaseForm
  attr_accessor :answer_type, :draft_question

  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }

  def submit
    return false if invalid?

    draft_question.answer_type = answer_type
    draft_question.answer_settings = default_answer_settings_for_answer_type # TODO: We should only clear this if the answer_type changes
    draft_question.save!(validate: false)
  end

private

  def default_answer_settings_for_answer_type
    case answer_type
    when "selection"
      Pages::SelectionsSettingsForm::DEFAULT_OPTIONS
    when "text", "date", "address"
      { input_type: nil }
    when "name"
      { input_type: nil, title_needed: nil }
    else
      {}
    end
  end
end
