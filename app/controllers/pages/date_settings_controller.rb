class Pages::DateSettingsController < PagesController
  def new
    @date_settings_form = Pages::DateSettingsForm.new(input_type: draft_question.answer_settings[:input_type])
    @date_settings_path = date_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :date_settings, locals: { current_form: }
  end

  def create
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @date_settings_form.submit
      redirect_to new_question_path(current_form)
    else
      render :date_settings, locals: { current_form: }
    end
  end

  def edit
    @date_settings_form = Pages::DateSettingsForm.new(input_type: draft_question.answer_settings[:input_type])
    @date_settings_path = date_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :date_settings, locals: { current_form: }
  end

  def update
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @date_settings_form.submit
      redirect_to edit_question_path(current_form)
    else
      page
      render :date_settings, locals: { current_form: }
    end
  end

private

  def date_settings_form_params
    params.require(:pages_date_settings_form).permit(:input_type).merge(draft_question:)
  end
end
