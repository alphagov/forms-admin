class Pages::AddOrEditQuestionService
  include Rails.application.routes.url_helpers

  def initialize(form_id:, existing_page_id: nil)
    @form_id = form_id
    @page_id = existing_page_id
    @is_editing = existing_page_id.present?
  end

  def new_or_edit_path_for_answer_type(answer_type)
    case answer_type
    when "selection"
      @is_editing ? selection_type_edit_path(@form_id, @page_id) : question_text_new_path(@form_id)
    when "text"
      @is_editing ? text_settings_edit_path(@form_id, @page_id) : text_settings_new_path(@form_id)
    when "date"
      @is_editing ? date_settings_edit_path(@form_id, @page_id) : date_settings_new_path(@form_id)
    when "address"
      @is_editing ? address_settings_edit_path(@form_id, @page_id) : address_settings_new_path(@form_id)
    when "name"
      @is_editing ? name_settings_edit_path(@form_id, @page_id) : name_settings_new_path(@form_id)
    else
      @is_editing ? edit_question_path(@form_id, @page_id) : new_question_path(@form_id)
    end
  end
end
