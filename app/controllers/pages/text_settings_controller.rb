class Pages::TextSettingsController < PagesController
  def new
    @text_settings_input = Pages::TextSettingsInput.new(input_type: draft_question.answer_settings[:input_type])
    @text_settings_path = text_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)
    render :text_settings, locals: { current_form: }
  end

  def create
    @text_settings_input = Pages::TextSettingsInput.new(text_settings_input_params)
    @text_settings_path = text_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)

    if @text_settings_input.submit
      redirect_to new_question_path(current_form.id)
    else
      render :text_settings, locals: { current_form: }
    end
  end

  def edit
    @text_settings_input = Pages::TextSettingsInput.new(input_type: draft_question.answer_settings[:input_type])
    @text_settings_path = text_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)
    render :text_settings, locals: { current_form: }
  end

  def update
    @text_settings_input = Pages::TextSettingsInput.new(text_settings_input_params)
    @text_settings_path = text_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)

    if @text_settings_input.submit
      redirect_to edit_question_path(current_form.id)
    else
      page
      render :text_settings, locals: { current_form: }
    end
  end

private

  def text_settings_input_params
    params.require(:pages_text_settings_input).permit(:input_type).merge(draft_question:)
  end
end
