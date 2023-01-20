class Pages::NameSettingsController < PagesController
  def new
    input_type = session.dig(:page, "answer_settings", "input_type")
    title_needed = session.dig(:page, "answer_settings", "title_needed")
    @name_settings_form = Forms::NameSettingsForm.new(input_type:, title_needed:)
    @name_settings_path = name_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render name_settings_view
  end

  def create
    @name_settings_form = Forms::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @name_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render name_settings_view
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_type answer_settings])
    input_type = @page&.answer_settings&.input_type
    title_needed = @page&.answer_settings&.title_needed
    @name_settings_form = Forms::NameSettingsForm.new(input_type:, title_needed:, page: @page)
    @name_settings_path = name_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render name_settings_view
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @name_settings_form = Forms::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @name_settings_form.submit(session)
      redirect_to edit_page_path(@form)
    else
      render name_settings_view
    end
  end

private

  def name_settings_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_name_settings_form).permit(:input_type, :title_needed).merge(form:)
  end

  def name_settings_view
    "pages/name_settings"
  end
end
