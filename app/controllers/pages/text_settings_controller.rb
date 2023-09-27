class Pages::TextSettingsController < PagesController
  def new
    @text_settings_form = Pages::TextSettingsForm.new(input_type: draft_question.answer_settings[:input_type])
    @text_settings_path = text_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/text_settings"
  end

  def create
    @text_settings_form = Pages::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @text_settings_form.submit
      redirect_to new_page_path(@form)
    else
      render "pages/text_settings"
    end
  end

  def edit
    @text_settings_form = Pages::TextSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      draft_question:)
    @text_settings_path = text_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render "pages/text_settings"
  end

  def update
    @text_settings_form = Pages::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @text_settings_form.submit
      redirect_to edit_page_path(@form)
    else
      render "pages/text_settings"
    end
  end

private

  def text_settings_form_params
    params.require(:pages_text_settings_form).permit(:input_type).merge(draft_question:)
  end
end
