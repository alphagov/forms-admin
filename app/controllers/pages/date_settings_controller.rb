class Pages::DateSettingsController < PagesController
  def new
    input_type = session.dig(:page, :answer_settings, :input_type)
    @date_settings_form = Pages::DateSettingsForm.new(input_type:)
    @date_settings_path = date_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :date_settings, locals: { current_form: }
  end

  def create
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @date_settings_form.submit(session)
      redirect_to new_question_path(current_form)
    else
      render :date_settings, locals: { current_form: }
    end
  end

  def edit
    page.load_from_session(session, %i[answer_settings])
    input_type = @page.answer_settings&.input_type
    @date_settings_form = Pages::DateSettingsForm.new(input_type:)
    @date_settings_path = date_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :date_settings, locals: { current_form: }
  end

  def update
    page
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @date_settings_form.submit(session)
      redirect_to edit_question_path(current_form)
    else
      render :date_settings, locals: { current_form: }
    end
  end

private

  def date_settings_form_params
    params.require(:pages_date_settings_form).permit(:input_type).merge(draft_question:)
  end
end
