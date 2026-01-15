class Pages::QuestionInput < BaseInput
  attr_accessor :question_text, :hint_text, :is_optional, :answer_type, :draft_question, :is_repeatable, :form_id

  # TODO: We could lose these attributes once we have a Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  attr_reader :selection_options # only used for displaying error

  validates :draft_question, presence: true
  validate :validate_question_text_presence
  validate :validate_question_text_length
  validates :hint_text, length: { maximum: 500 }
  validates :is_optional, inclusion: { in: %w[false true] }
  validates :is_repeatable, inclusion: { in: %w[false true] }
  validate :validate_number_of_selection_options

  def submit
    return false if invalid?

    prepare_for_save

    attrs = {
      form_id:,
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
      answer_settings:,
      page_heading:,
      guidance_markdown:,
      answer_type:,
    }

    if draft_question.form.available_languages.include?("cy")
      attrs[:answer_settings_cy] = answer_settings_cy
    end

    Page.create_and_update_form!(**attrs)
  end

  def update_page(page)
    return false if invalid?

    prepare_for_save

    attrs = {
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
      answer_settings:,
      page_heading:,
      guidance_markdown:,
      answer_type:,
    }

    if draft_question.form.available_languages.include?("cy")
      attrs[:answer_settings_cy] = answer_settings_cy(page)
    end

    page.assign_attributes(**attrs)

    page.save_and_update_form
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

  def validate_question_text_presence
    return if question_text.present?

    translation_key = answer_type == "file" ? :blank_file : :blank
    errors.add(:question_text, translation_key)
  end

  def validate_question_text_length
    return if question_text.blank? || question_text.length <= QuestionTextValidation::QUESTION_TEXT_MAX_LENGTH

    translation_key = answer_type == "file" ? :too_long_file : :too_long
    errors.add(:question_text, translation_key, count: QuestionTextValidation::QUESTION_TEXT_MAX_LENGTH)
  end

private

  def prepare_for_save
    compact_answer_settings
    update_draft_question
  end

  def compact_answer_settings
    answer_settings.delete(:none_of_the_above_question) if answer_settings[:none_of_the_above_question].blank?
  end

  def update_draft_question
    draft_question.assign_attributes(
      question_text:,
      hint_text:,
      is_optional:,
      is_repeatable:,
    )

    draft_question.save!
  end

  def answer_settings_cy(page = nil)
    return unless answer_type == "selection"

    answer_settings_cloned = DataStructType.new.cast_value(answer_settings.as_json)

    answer_settings_cloned.selection_options.each.with_index do |selection_option, index|
      welsh_name = page&.answer_settings_cy&.dig("selection_options", index, "name")

      selection_option.name = (welsh_name.presence || "")
    end

    if answer_settings_cloned.none_of_the_above_question.present?
      welsh_none_of_the_above_question = page&.answer_settings_cy&.dig("none_of_the_above_question", "question_text")
      answer_settings_cloned.none_of_the_above_question.question_text = welsh_none_of_the_above_question || ""
    end

    answer_settings_cloned
  end
end
