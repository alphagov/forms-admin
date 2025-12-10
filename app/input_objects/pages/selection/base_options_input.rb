class Pages::Selection::BaseOptionsInput < BaseInput
  include LoggingHelper

  INCLUDE_NONE_OF_THE_ABOVE_OPTIONS = %w[true false].freeze
  MAXIMUM_CHOOSE_ONLY_ONE_OPTION = 1000
  MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION = 30

  attr_accessor :include_none_of_the_above, :draft_question

  def submit
    return false if invalid?

    draft_question.assign_attributes(answer_settings:, is_optional: include_none_of_the_above)

    success = draft_question.save!(validate: false)
    log_submission if success

    success
  end

  def include_none_of_the_above_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end

  def only_one_option?
    draft_question.answer_settings[:only_one_option] == "true"
  end

  def maximum_options
    only_one_option? ? MAXIMUM_CHOOSE_ONLY_ONE_OPTION : MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION
  end

private

  def maximum_error_type
    only_one_option? ? :maximum_choose_only_one_option : :maximum_choose_more_than_one_option
  end

  def answer_settings
    draft_question.answer_settings.merge({ selection_options: })
  end

  def is_bulk_entry?
    false
  end

  def log_submission
    log_selection_question_options_submitted(
      is_bulk_entry: is_bulk_entry?,
      options_count: selection_options.length,
      only_one_option: only_one_option?,
    )
  end
end
