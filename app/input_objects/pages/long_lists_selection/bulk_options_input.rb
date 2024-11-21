class Pages::LongListsSelection::BulkOptionsInput < BaseInput
  include LoggingHelper

  MAXIMUM_CHOOSE_ONLY_ONE_OPTION = 1000
  MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION = 30

  attr_accessor :include_none_of_the_above, :draft_question, :bulk_selection_options

  validates :draft_question, presence: true
  validates :include_none_of_the_above, inclusion: { in: %w[true false] }
  validate :bulk_selection_options, :validate_selection_options

  def assign_form_values
    self.bulk_selection_options = draft_question.answer_settings[:selection_options].map { |option| option[:name] }.join("\n")
    self.include_none_of_the_above = draft_question.is_optional
  end

  def submit
    return false if invalid?

    # Set answer_settings for the draft_question
    draft_question
      .assign_attributes({ answer_settings:,
                           is_optional: include_none_of_the_above })

    success = draft_question.save!(validate: false)
    log_submission if success

    success
  end

  def none_of_the_above_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end

  def only_one_option?
    draft_question.answer_settings[:only_one_option] == "true"
  end

private

  def validate_selection_options
    options = selection_options_without_blanks

    return errors.add(:bulk_selection_options, :minimum) if options.length < 2
    return errors.add(:bulk_selection_options, maximum_error_type) if options.length > maximum_options

    duplicates = selection_options_without_blanks.filter { |option| selection_options_without_blanks.count(option) > 1 }
    errors.add(:bulk_selection_options, I18n.t("activemodel.errors.models.pages/long_lists_selection/bulk_options_input.attributes.bulk_selection_options.uniqueness", duplicate: duplicates.first)) if duplicates.any?
  end

  def selection_options_without_blanks
    bulk_selection_options.split(/\n/).map(&:strip).compact_blank
  end

  def selection_options
    selection_options_without_blanks.map { |option| { name: option } }
  end

  def answer_settings
    draft_question.answer_settings.merge({ selection_options: })
  end

  def maximum_error_type
    only_one_option? ? :maximum_choose_only_one_option : :maximum_choose_more_than_one_option
  end

  def maximum_options
    only_one_option? ? MAXIMUM_CHOOSE_ONLY_ONE_OPTION : MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION
  end

  def log_submission
    log_selection_question_options_submitted(is_bulk_entry: true, options_count: selection_options.length, only_one_option: only_one_option?)
  end
end
