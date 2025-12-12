class Pages::Selection::BulkOptionsInput < Pages::Selection::BaseOptionsInput
  attr_accessor :bulk_selection_options

  validates :draft_question, presence: true
  validates :include_none_of_the_above, inclusion: { in: INCLUDE_NONE_OF_THE_ABOVE_OPTIONS }
  validate :bulk_selection_options, :validate_selection_options

  def assign_form_values
    self.bulk_selection_options = draft_question.answer_settings[:selection_options].map { |option| option[:name] }.join("\n")
    self.include_none_of_the_above = selected_none_of_the_above_option(draft_question)
  end

  def selection_options_without_blanks
    return [] if bulk_selection_options.nil?

    bulk_selection_options.split(/\n/).map(&:strip).compact_blank
  end

  def selection_options
    selection_options_without_blanks.map { |option| { name: option } }
  end

  def is_bulk_entry?
    true
  end

private

  def validate_selection_options
    options = selection_options_without_blanks

    return errors.add(:bulk_selection_options, :minimum) if options.length < 2
    return errors.add(:bulk_selection_options, maximum_error_type) if options.length > maximum_options

    duplicates = selection_options_without_blanks.filter { |option| selection_options_without_blanks.count(option) > 1 }
    if duplicates.any?
      errors.add(:bulk_selection_options, I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.bulk_selection_options.uniqueness", duplicate: duplicates.first))
    end
  end
end
