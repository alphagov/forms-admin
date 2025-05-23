class Pages::TypeOfAnswerInput < BaseInput
  attr_accessor :answer_type, :draft_question, :current_form

  SELECTION_DEFAULT_OPTIONS = { selection_options: [{ name: "" }, { name: "" }] }.freeze

  validates :draft_question, presence: true
  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }
  validate :not_more_than_4_file_upload_questions

  def submit
    return false if invalid?
    return true unless answer_type_changed?

    draft_question
      .assign_attributes({ answer_type:, answer_settings: default_answer_settings_for_answer_type })

    draft_question.save!(validate: false)
  end

private

  def not_more_than_4_file_upload_questions
    if answer_type.present? && answer_type.to_sym == :file && current_form.file_upload_question_count >= 4
      errors.add(:answer_type, :cannot_add_more_file_upload_questions)
    end
  end

  def answer_type_changed?
    answer_type != draft_question.answer_type
  end

  def default_answer_settings_for_answer_type
    case answer_type.to_sym
    when :selection
      SELECTION_DEFAULT_OPTIONS
    when :text, :date, :address
      { input_type: nil }
    when :name
      { input_type: nil, title_needed: nil }
    else
      {}
    end
  end
end
