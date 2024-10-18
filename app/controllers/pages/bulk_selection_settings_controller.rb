class Pages::BulkSelectionSettingsController < PagesController
  def new
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(draft_question:)
    @bulk_selection_settings_input.assign_form_values
    @bulk_selection_settings_path = bulk_selection_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)
    render :bulk_selection_settings, locals: { current_form: }
  end

  def create
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(include_none_of_the_above: include_none_of_the_above_param_values,
                                                                           bulk_selection_options: bulk_selection_options_param_values,
                                                                           draft_question:)
    @bulk_selection_settings_path = bulk_selection_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)

    if @bulk_selection_settings_input.submit
      redirect_to new_question_path(current_form)
    else
      render :bulk_selection_settings, locals: { current_form: }
    end
  end

  def edit
    @bulk_selection_settings_path = bulk_selection_settings_update_path(current_form)
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(draft_question:)
    @bulk_selection_settings_input.assign_form_values
    @back_link_url = edit_question_path(current_form, page)
    render :bulk_selection_settings, locals: { current_form: }
  end

  def update
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(include_none_of_the_above: include_none_of_the_above_param_values,
                                                                           bulk_selection_options: bulk_selection_options_param_values,
                                                                           draft_question:)
    @bulk_selection_settings_path = bulk_selection_settings_update_path(current_form)
    @back_link_url = edit_question_path(current_form, page)

    if @bulk_selection_settings_input.submit
      redirect_to edit_question_path(current_form)
    else
      render :bulk_selection_settings, locals: { current_form: }
    end
  end

private

  def include_none_of_the_above_param_values
    bulk_selection_settings_input_params[:include_none_of_the_above]
  end

  def bulk_selection_options_param_values
    bulk_selection_settings_input_params[:bulk_selection_options]
  end

  def bulk_selection_settings_input_params
    params.require(:pages_bulk_selection_settings_input)
          .permit(:include_none_of_the_above, :bulk_selection_options).to_h.deep_symbolize_keys
  end
end
