class Pages::TextSettingsController < PagesController
  def new
    input_type = session.dig(:page, "answer_settings", "input_type")
    @text_settings_form = Forms::TextSettingsForm.new(input_type:)
    @text_settings_path = text_settings_create_path(@form)
    render "pages/text_settings"
  end

  def create
    @text_settings_form = Forms::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_create_path(@form)

    if @text_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render "pages/text_settings"
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    input_type = @page&.answer_settings&.input_type
    @text_settings_form = Forms::TextSettingsForm.new(input_type:, page: @page)
    @text_settings_path = text_settings_update_path(@form)
    render "pages/text_settings"
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @text_settings_form = Forms::TextSettingsForm.new(text_settings_form_params)
    @text_settings_path = text_settings_update_path(@form)

    if @text_settings_form.assign_values_to_page(@page) && @page.save!
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
