module LoggingHelper
  def log_selection_question_options_submitted(is_bulk_entry:, options_count:, only_one_option:)
    Rails.logger.info("Submitted selection options for a selection question", {
      is_bulk_entry:,
      options_count:,
      only_one_option:,
    })
  end

  def log_form_copied(original_form_id:, copied_form_id:, creator_id:)
    Rails.logger.info("Form copied", {
      original_form_id:,
      copied_form_id:,
      creator_id:,
    })
  end
end
