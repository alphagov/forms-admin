class Pages::LongListsSelection::BulkOptionsInput < BaseInput
  DEFAULT_OPTIONS = { selection_options: [],
                      only_one_option: "true",
                      include_none_of_the_above: false }.freeze

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

    draft_question.save!(validate: false)
  end

  def none_of_the_above_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end

private

  def validate_selection_options
    unique_options = unique_selection_options

    return errors.add(:bulk_selection_options, :minimum) if unique_options.length < 2

    errors.add(:bulk_selection_options, :maximum) if unique_options.length > 1000
  end

  def unique_selection_options
    bulk_selection_options.split(/\n/).map(&:strip).compact_blank.uniq
  end

  def selection_options
    unique_selection_options.map { |option| { name: option } }
  end

  def answer_settings
    draft_question.answer_settings.merge({ selection_options: })
  end
end
