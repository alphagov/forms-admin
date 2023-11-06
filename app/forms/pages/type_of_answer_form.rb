class Pages::TypeOfAnswerForm < BaseForm
  attr_accessor :answer_type, :draft_question

  validates :draft_question, presence: true
  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }

  def submit(session)
    return false if invalid?

    draft_question
      .assign_attributes({ answer_type:, answer_settings: default_answer_settings_for_answer_type })

    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = { answer_type:, answer_settings: default_answer_settings_for_answer_type }
  end

  private
  def default_answer_settings_for_answer_type
    case answer_type.to_sym
    when :selection
      Pages::SelectionsSettingsForm::DEFAULT_OPTIONS
    when :text, :date, :address
      { input_type: nil }
    when :name
      { input_type: nil, title_needed: nil }
    else
      {}
    end
  end

end
