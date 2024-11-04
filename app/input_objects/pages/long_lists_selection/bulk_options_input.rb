class Pages::LongListsSelection::BulkOptionsInput < BaseInput
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
    options = selection_options_without_blanks

    return errors.add(:bulk_selection_options, :minimum) if options.length < 2
    return errors.add(:bulk_selection_options, :maximum) if options.length > 1000

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
end
