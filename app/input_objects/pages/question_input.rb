class Pages::QuestionInput < BaseInput
  include QuestionTextValidation

  attr_accessor :question_text, :hint_text, :is_optional, :answer_type, :draft_question, :is_repeatable, :form_id

  # TODO: We could lose these attributes once we have a Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  attr_reader :selection_options # only used for displaying error

  validates :draft_question, presence: true
  validates :hint_text, length: { maximum: 500 }
  validates :is_optional, inclusion: { in: %w[false true] }
  validates :is_repeatable, inclusion: { in: %w[false true] }
  validate :validate_number_of_selection_options

  def submit
    return false if invalid?

    draft_question.assign_attributes(
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
    )

    draft_question.save!(validate: false)

    PageRepository.create!(form_id:,
                           question_text:,
                           hint_text:,
                           is_optional:,
                           is_repeatable:,
                           answer_settings:,
                           page_heading:,
                           guidance_markdown:,
                           answer_type:)
  end

  def update_page(page)
    return false if invalid?

    draft_question.assign_attributes(
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
    )

    draft_question.save!(validate: false)

    PageRepository.save!(page)
  end

  def default_options
    [OpenStruct.new(id: "false"), OpenStruct.new(id: "true")]
  end

  def repeatable_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end

  def validate_number_of_selection_options
    return if draft_question.nil?
    return unless @draft_question.answer_type == "selection"
    return unless @draft_question.answer_settings[:only_one_option] == "false" &&
      @draft_question.answer_settings[:selection_options].length > 30

    errors.add(:selection_options, :too_many_selection_options)
  end
end
