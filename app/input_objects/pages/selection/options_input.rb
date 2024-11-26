class Pages::Selection::OptionsInput < BaseInput
  include LoggingHelper

  DEFAULT_OPTIONS = { selection_options: [{ name: "" }, { name: "" }] }.freeze
  INCLUDE_NONE_OF_THE_ABOVE_OPTIONS = %w[true false].freeze
  MAXIMUM_CHOOSE_ONLY_ONE_OPTION = 1000
  MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION = 30

  attr_accessor :selection_options, :include_none_of_the_above, :draft_question

  validate :selection_options, :validate_selection_options
  validates :include_none_of_the_above, inclusion: { in: INCLUDE_NONE_OF_THE_ABOVE_OPTIONS }

  def add_another
    selection_options.append({ name: "" })
  end

  def remove(index)
    selection_options.delete_at(index)
  end

  def answer_settings
    draft_question.answer_settings.merge({ selection_options: })
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

  def selection_options_form_objects
    selection_options.map { |option| OpenStruct.new(name: option[:name]) }
  end

  def include_none_of_the_above_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end

  def maximum_options
    only_one_option? ? MAXIMUM_CHOOSE_ONLY_ONE_OPTION : MAXIMUM_CHOOSE_MORE_THAN_ONE_OPTION
  end

  def only_one_option?
    draft_question.answer_settings[:only_one_option] == "true"
  end

private

  def validate_selection_options
    filter_out_blank_options

    return errors.add(:selection_options, :minimum) if selection_options.length < 2
    return errors.add(:selection_options, maximum_error_type) if selection_options.length > maximum_options

    errors.add(:selection_options, :uniqueness) if selection_options.uniq.length != selection_options.length
  end

  def filter_out_blank_options
    self.selection_options = selection_options.filter { |option| option[:name].present? }
  end

  def maximum_error_type
    draft_question.answer_settings[:only_one_option] == "true" ? :maximum_choose_only_one_option : :maximum_choose_more_than_one_option
  end

  def log_submission
    log_selection_question_options_submitted(is_bulk_entry: false, options_count: selection_options.length, only_one_option: only_one_option?)
  end
end
