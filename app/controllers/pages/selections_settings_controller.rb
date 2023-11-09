class Pages::SelectionsSettingsController < PagesController
  def new
    @selections_settings_form = Pages::SelectionsSettingsForm.new(draft_question.answer_settings)
    @selections_settings_path = selections_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)
    render :selections_settings, locals: { current_form: }
  end

  def create
    @selections_settings_form = Pages::SelectionsSettingsForm.new(selection_options: selection_options_param_values,
                                                                  only_one_option: only_one_option_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selections_settings_path = selections_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)

    if params[:add_another]
      @selections_settings_form.add_another
      render :selections_settings, locals: { current_form: }
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render :selections_settings, locals: { current_form: }
    elsif @selections_settings_form.submit
      redirect_to new_question_path(current_form)
    else
      render :selections_settings, locals: { current_form: }
    end
  end

  def edit
    @selections_settings_path = selections_settings_update_path(current_form)
    @selections_settings_form = Pages::SelectionsSettingsForm.new(only_one_option: draft_question.answer_settings.with_indifferent_access[:only_one_option],
                                                                  selection_options: draft_question.answer_settings.with_indifferent_access[:selection_options]
                                                                                                   .map { |option| { name: option[:name] } },
                                                                  include_none_of_the_above: draft_question.is_optional,
                                                                  draft_question:)
    @back_link_url = edit_question_path(current_form, page)
    render :selections_settings, locals: { current_form: }
  end

  def update
    @selections_settings_form = Pages::SelectionsSettingsForm.new(selection_options: selection_options_param_values,
                                                                  only_one_option: only_one_option_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selections_settings_path = selections_settings_update_path(current_form)
    @back_link_url = edit_question_path(current_form, page)

    if params[:add_another]
      @selections_settings_form.add_another
      render :selections_settings, locals: { current_form: }
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render :selections_settings, locals: { current_form: }
    elsif @selections_settings_form.submit
      redirect_to edit_question_path(current_form)
    else
      render :selections_settings, locals: { current_form: }
    end
  end

private

  def selection_options_param_values
    selections_settings_form_params[:selection_options] ? selections_settings_form_params[:selection_options].values : []
  end

  def only_one_option_param_values
    selections_settings_form_params[:only_one_option]
  end

  def include_none_of_the_above_param_values
    selections_settings_form_params[:include_none_of_the_above]
  end

  def selections_settings_form_params
    params.require(:pages_selections_settings_form)
          .permit(:only_one_option, :include_none_of_the_above, selection_options: [:name]).to_h.deep_symbolize_keys
  end
end
