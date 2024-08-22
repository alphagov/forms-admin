class Pages::QuestionInput < BaseInput
  include QuestionTextValidation

  attr_accessor :question_text, :hint_text, :is_optional, :answer_type, :draft_question, :is_repeatable

  # TODO: We could lose these attributes once we have an Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  validates :draft_question, presence: true
  validates :hint_text, length: { maximum: 500 }
  validates :is_optional, inclusion: { in: %w[false true] }
  validates :is_repeatable, inclusion: { in: %w[false true] }, if: -> { Settings.features.repeatable_page_enabled }

  def submit
    return false if invalid?

    draft_question.assign_attributes(
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
    )

    draft_question.save!(validate: false)
  end

  def default_options
    [OpenStruct.new(id: "false"), OpenStruct.new(id: "true")]
  end

  def repeatable_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end
end
