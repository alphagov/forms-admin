module LoggingHelper
  def log_selection_question_options_submitted(is_bulk_entry:, options_count:, only_one_option:)
    Rails.logger.info("Submitted selection options for a selection question", {
      is_bulk_entry:,
      options_count:,
      only_one_option:,
    })
  end
end
