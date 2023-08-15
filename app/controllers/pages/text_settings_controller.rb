class Pages::TextSettingsController < PagesController
  def new
    input_type = session.dig(:page, "answer_settings", "input_type")
    @text_settings_form = Forms::TextSettingsForm.new(input_type:)
    @text_settings_path = text_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/text_settings"
  end

  def create
    @text_settings_form = Forms::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @text_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render "pages/text_settings"
    end
  end

  def edit
    page.load_from_session(session, %w[answer_type answer_settings])
    input_type = @page&.answer_settings&.input_type
    @text_settings_form = Forms::TextSettingsForm.new(input_type:, page: @page)
    @text_settings_path = text_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render "pages/text_settings"
  end

  def update
    page
    @text_settings_form = Forms::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @text_settings_form.submit(session)
      redirect_to edit_page_path(@form)
    else
      render "pages/text_settings"
    end
  end

private

  def text_settings_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_text_settings_form).permit(:input_type).merge(form:)
  end
end
