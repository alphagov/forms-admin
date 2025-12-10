class Pages::Selection::BulkOptionsController < PagesController
  def new
    @bulk_options_input = Pages::Selection::BulkOptionsInput.new(draft_question:)
    @bulk_options_input.assign_form_values
    @bulk_options_path = selection_bulk_options_create_path(current_form.id)
    @back_link_url = selection_type_new_path(current_form.id)
    render "pages/selection/bulk_options", locals: { current_form: }
  end

  def create
    @bulk_options_input = Pages::Selection::BulkOptionsInput.new(**bulk_options_input_params,
      draft_question:)
    @bulk_options_path = selection_bulk_options_create_path(current_form.id)
    @back_link_url = selection_type_new_path(current_form.id)

    if @bulk_options_input.submit
      if @bulk_options_input.include_none_of_the_above_with_question?
        redirect_to selection_none_of_the_above_new_path(current_form.id)
      else
        redirect_to new_question_path(current_form.id)
      end
    else
      render "pages/selection/bulk_options", locals: { current_form: }
    end
  end

  def edit
    @bulk_options_path = selection_bulk_options_update_path(current_form.id)
    @bulk_options_input = Pages::Selection::BulkOptionsInput.new(draft_question:)
    @bulk_options_input.assign_form_values
    @back_link_url = edit_question_path(current_form.id, page.id)
    render "pages/selection/bulk_options", locals: { current_form: }
  end

  def update
    @bulk_options_input = Pages::Selection::BulkOptionsInput.new(**bulk_options_input_params,
      draft_question:)
    @bulk_options_path = selection_bulk_options_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id, page.id)

    if @bulk_options_input.submit
      if @bulk_options_input.include_none_of_the_above_with_question?
        redirect_to selection_none_of_the_above_edit_path(current_form.id)
      else
        redirect_to edit_question_path(current_form.id)
      end
    else
      render "pages/selection/bulk_options", locals: { current_form: }
    end
  end

private

  def bulk_options_input_params
    params.require(:pages_selection_bulk_options_input)
          .permit(:include_none_of_the_above, :bulk_selection_options).to_h.deep_symbolize_keys
  end
end
