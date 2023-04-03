class Pages::DateSettingsController < PagesController
  def new
    authorize @form, :can_view_form?

    input_type = session.dig(:page, "answer_settings", "input_type")
    @date_settings_form = Forms::DateSettingsForm.new(input_type:)
    @date_settings_path = date_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/date_settings"
  end

  def create
    authorize @form, :can_view_form?

    @date_settings_form = Forms::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @date_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render "pages/date_settings"
    end
  end

  def edit
    authorize @form, :can_view_form?

    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_type answer_settings])
    input_type = @page&.answer_settings&.input_type
    @date_settings_form = Forms::DateSettingsForm.new(input_type:, page: @page)
    @date_settings_path = date_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render "pages/date_settings"
  end

  def update
    authorize @form, :can_view_form?

    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @date_settings_form = Forms::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @date_settings_form.submit(session)
      redirect_to edit_page_path(@form)
    else
      render "pages/date_settings"
    end
  end

private

  def date_settings_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_date_settings_form).permit(:input_type).merge(form:)
  end
end
