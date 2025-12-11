class Pages::Selection::BaseOptionsInput < BaseInput
  include LoggingHelper

  INCLUDE_NONE_OF_THE_ABOVE_OPTIONS = %w[yes yes_with_question no].freeze
  MAXIMUM_CHOOSE_ONLY_ONE_OPTION = 1000
  MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION = 30

  attr_accessor :include_none_of_the_above, :draft_question

  def submit
    return false if invalid?

    is_optional = include_none_of_the_above != "no"
    draft_question.assign_attributes(answer_settings:, is_optional:)

    success = draft_question.save!(validate: false)
    log_submission if success

    success
  end

  def include_none_of_the_above_options
    if FeatureService.enabled?(:describe_none_of_the_above_enabled)
      [OpenStruct.new(id: "yes"), OpenStruct.new(id: "yes_with_question"), OpenStruct.new(id: "no")]
    else
      [OpenStruct.new(id: "yes"), OpenStruct.new(id: "no")]
    end
  end

  def include_none_of_the_above_with_question?
    include_none_of_the_above == "yes_with_question"
  end

  def only_one_option?
    draft_question.answer_settings[:only_one_option] == "true"
  end

  def maximum_options
    only_one_option? ? MAXIMUM_CHOOSE_ONLY_ONE_OPTION : MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION
  end

private

  def selected_none_of_the_above_option(draft_question)
    return nil if draft_question.is_optional.nil?
    return "no" unless draft_question.is_optional
    return "yes_with_question" if draft_question.answer_settings.key?(:none_of_the_above_question)

    "yes"
  end

  def maximum_error_type
    only_one_option? ? :maximum_choose_only_one_option : :maximum_choose_more_than_one_option
  end

  def answer_settings
    new_answer_settings = draft_question.answer_settings.deep_dup

    if include_none_of_the_above == "yes_with_question"
      new_answer_settings[:none_of_the_above_question] = {} if new_answer_settings[:none_of_the_above_question].nil?
    else
      new_answer_settings.delete(:none_of_the_above_question)
    end

    new_answer_settings.merge({ selection_options: selection_options_with_value })
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

  def selection_options_with_value
    selection_options.map { |option| { name: option[:name], value: option[:name] } }
  end
end
