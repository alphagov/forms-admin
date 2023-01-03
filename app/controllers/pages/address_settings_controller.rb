class Pages::AddressSettingsController < PagesController
  def new
    input_type = session.dig(:page, "answer_settings", "input_type")
    @address_settings_form = Forms::AddressSettingsForm.new(input_type:)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/address_settings"
  end

  def create
    @address_settings_form = Forms::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @address_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render "pages/address_settings"
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    input_type = @page&.answer_settings&.input_type
    @address_settings_form = Forms::AddressSettingsForm.new(input_type:, page: @page)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render "pages/address_settings"
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @address_settings_form = Forms::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @address_settings_form.assign_values_to_page(@page) && @page.save!
      redirect_to edit_page_path(@form)
    else
      render "pages/address_settings"
    end
  end

private

  def address_settings_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_address_settings_form).permit(:input_type).merge(form:)
  end
end
