class Pages::TextSettingsController < PagesController
  def new
    input_type = session.dig(:page, :answer_settings, :input_type)
    @text_settings_form = Pages::TextSettingsForm.new(input_type:)
    @text_settings_path = text_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :text_settings, locals: { current_form: }
  end

  def create
    @text_settings_form = Pages::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @text_settings_form.submit(session)
      redirect_to new_question_path(current_form)
    else
      render :text_settings, locals: { current_form: }
    end
  end

  def edit
    page.load_from_session(session, %i[answer_settings])
    input_type = @page.answer_settings&.input_type
    @text_settings_form = Pages::TextSettingsForm.new(input_type:)
    @text_settings_path = text_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :text_settings, locals: { current_form: }
  end

  def update
    page
    @text_settings_form = Pages::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @text_settings_form.submit(session)
      redirect_to edit_question_path(current_form)
    else
      render :text_settings, locals: { current_form: }
    end
  end

private

  def text_settings_form_params
    params.require(:pages_text_settings_form).permit(:input_type).merge(draft_question:)
  end
end
