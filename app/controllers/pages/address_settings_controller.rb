class Pages::AddressSettingsController < PagesController
  def new
    authorize @form, :can_view_form?

    uk_address = session.dig(:page, "answer_settings", "input_type", "uk_address")
    international_address = session.dig(:page, "answer_settings", "input_type", "international_address")
    @address_settings_form = Forms::AddressSettingsForm.new(uk_address:, international_address:)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render address_settings_view
  end

  def create
    authorize @form, :can_view_form?

    @address_settings_form = Forms::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @address_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render address_settings_view
    end
  end

  def edit
    authorize @form, :can_view_form?

    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_type answer_settings])
    input_type = @page&.answer_settings&.input_type
    uk_address = input_type&.uk_address
    international_address = input_type&.international_address
    @address_settings_form = Forms::AddressSettingsForm.new(uk_address:, international_address:, page: @page)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render address_settings_view
  end

  def update
    authorize @form, :can_view_form?

    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @address_settings_form = Forms::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @address_settings_form.submit(session)
      redirect_to edit_page_path(@form)
    else
      render address_settings_view
    end
  end

private

  def address_settings_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_address_settings_form).permit(:uk_address, :international_address).merge(form:)
  end

  def address_settings_view
    "pages/address_settings"
  end
end
