class Pages::TypeOfAnswerInput < BaseInput
  attr_accessor :answer_type, :draft_question, :answer_types

  SELECTION_DEFAULT_OPTIONS = { selection_options: [{ name: "" }, { name: "" }] }.freeze

  validates :draft_question, presence: true
  validates :answer_type, presence: true, inclusion: { in: :answer_types }

  def submit
    return false if invalid?
    return true unless answer_type_changed?

    draft_question
      .assign_attributes({ answer_type:, answer_settings: default_answer_settings_for_answer_type })

    draft_question.save!(validate: false)
  end

private

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
