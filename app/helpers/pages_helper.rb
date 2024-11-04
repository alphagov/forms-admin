module PagesHelper
  def selection_options_new_path_for_draft_question(draft_question)
    options = draft_question_selection_options(draft_question)
    if options.present? && options.length > 30
      long_lists_selection_bulk_options_new_path(form_id: draft_question.form_id)
    else
      long_lists_selection_options_new_path(form_id: draft_question.form_id)
    end
  end

  def selection_options_edit_path_for_draft_question(draft_question)
    options = draft_question_selection_options(draft_question)
    if options.present? && options.length > 30
      long_lists_selection_bulk_options_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id)
    else
      long_lists_selection_options_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id)
    end
  end

  def draft_question_selection_options(draft_question)
    draft_question.answer_settings[:selection_options]
  end
end
