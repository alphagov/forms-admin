class Pages::DateSettingsController < PagesController
  def new
    @date_settings_input = Pages::DateSettingsInput.new(input_type: draft_question.answer_settings[:input_type])
    @date_settings_path = date_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)
    render :date_settings, locals: { current_form: }
  end

  def create
    @date_settings_input = Pages::DateSettingsInput.new(date_settings_input_params)
    @date_settings_path = date_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)

    if @date_settings_input.submit
      redirect_to new_question_path(current_form.id)
    else
      render :date_settings, locals: { current_form: }
    end
  end

  def edit
    @date_settings_input = Pages::DateSettingsInput.new(input_type: draft_question.answer_settings[:input_type])
    @date_settings_path = date_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)
    render :date_settings, locals: { current_form: }
  end

  def update
    @date_settings_input = Pages::DateSettingsInput.new(date_settings_input_params)
    @date_settings_path = date_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)

    if @date_settings_input.submit
      redirect_to edit_question_path(current_form.id)
    else
      page
      render :date_settings, locals: { current_form: }
    end
  end

private

  def date_settings_input_params
    params.require(:pages_date_settings_input).permit(:input_type).merge(draft_question:)
  end
end
