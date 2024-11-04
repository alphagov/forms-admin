class Pages::LongListsSelection::BulkOptionsController < PagesController
  def new
    @bulk_options_input = Pages::LongListsSelection::BulkOptionsInput.new(draft_question:)
    @bulk_options_input.assign_form_values
    @bulk_options_path = long_lists_selection_bulk_options_create_path(current_form)
    @back_link_url = long_lists_selection_type_new_path(current_form)
    render "pages/long_lists_selection/bulk_options", locals: { current_form: }
  end

  def create
    @bulk_options_input = Pages::LongListsSelection::BulkOptionsInput.new(**bulk_options_input_params,
                                                                           draft_question:)
    @bulk_options_path = long_lists_selection_bulk_options_create_path(current_form)
    @back_link_url = long_lists_selection_type_new_path(current_form)

    if @bulk_options_input.submit
      redirect_to new_question_path(current_form)
    else
      render "pages/long_lists_selection/bulk_options", locals: { current_form: }
    end
  end

  def edit
    @bulk_options_path = long_lists_selection_bulk_options_update_path(current_form)
    @bulk_options_input = Pages::LongListsSelection::BulkOptionsInput.new(draft_question:)
    @bulk_options_input.assign_form_values
    @back_link_url = edit_question_path(current_form, page)
    render "pages/long_lists_selection/bulk_options", locals: { current_form: }
  end

  def update
    @bulk_options_input = Pages::LongListsSelection::BulkOptionsInput.new(**bulk_options_input_params,
                                                                           draft_question:)
    @bulk_options_path = long_lists_selection_bulk_options_update_path(current_form)
    @back_link_url = edit_question_path(current_form, page)

    if @bulk_options_input.submit
      redirect_to edit_question_path(current_form)
    else
      render "pages/long_lists_selection/bulk_options", locals: { current_form: }
    end
  end

private

  def bulk_options_input_params
    params.require(:pages_long_lists_selection_bulk_options_input)
          .permit(:include_none_of_the_above, :bulk_selection_options).to_h.deep_symbolize_keys
  end
end
