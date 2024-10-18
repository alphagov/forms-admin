class Pages::BulkSelectionSettingsController < PagesController
  def new
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(draft_question:, include_none_of_the_above: draft_question.is_optional)
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

    if params[:add_another]
      @bulk_selection_settings_input.add_another
      render :bulk_selection_settings, locals: { current_form: }
    elsif params[:remove]
      @bulk_selection_settings_input.remove(params[:remove].to_i)
      render :bulk_selection_settings, locals: { current_form: }
    elsif @bulk_selection_settings_input.submit
      redirect_to new_question_path(current_form)
    else
      render :bulk_selection_settings, locals: { current_form: }
    end
  end

  def edit
    @bulk_selection_settings_path = bulk_selection_settings_update_path(current_form)
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(include_none_of_the_above: draft_question.is_optional,
                                                                           draft_question:)
    @back_link_url = edit_question_path(current_form, page)
    render :bulk_selection_settings, locals: { current_form: }
  end

  def update
    @bulk_selection_settings_input = Pages::BulkSelectionSettingsInput.new(include_none_of_the_above: include_none_of_the_above_param_values,
                                                                           bulk_selection_options: bulk_selection_options_param_values,
                                                                           draft_question:)
    @bulk_selection_settings_path = bulk_selection_settings_update_path(current_form)
    @back_link_url = edit_question_path(current_form, page)

    if params[:add_another]
      @bulk_selection_settings_input.add_another
      render :bulk_selection_settings, locals: { current_form: }
    elsif params[:remove]
      @bulk_selection_settings_input.remove(params[:remove].to_i)
      render :bulk_selection_settings, locals: { current_form: }
    elsif @bulk_selection_settings_input.submit
      redirect_to edit_question_path(current_form)
    else
      render :bulk_selection_settings, locals: { current_form: }
    end
  end

private

  def selection_options_param_values
    bulk_selection_settings_input_params[:selection_options] ? bulk_selection_settings_input_params[:selection_options].values : []
  end

  def only_one_option_param_values
    bulk_selection_settings_input_params[:only_one_option]
  end

  def include_none_of_the_above_param_values
    bulk_selection_settings_input_params[:include_none_of_the_above]
  end

  def bulk_selection_options_param_values
    bulk_selection_settings_input_params[:bulk_selection_options]
  end

  def bulk_selection_settings_input_params
    params.require(:pages_bulk_selection_settings_input)
          .permit(:only_one_option, :include_none_of_the_above, :bulk_selection_options, selection_options: [:name]).to_h.deep_symbolize_keys
  end
end
