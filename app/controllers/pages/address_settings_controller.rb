class Pages::AddressSettingsController < PagesController
  def new
    uk_address = session.dig(:page, :answer_settings, :input_type, :uk_address)
    international_address = session.dig(:page, :answer_settings, :input_type, :international_address)
    @address_settings_form = Pages::AddressSettingsForm.new(uk_address:, international_address:)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render address_settings_view
  end

  def create
    @address_settings_form = Pages::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @address_settings_form.submit(session)
      redirect_to new_question_path(@form)
    else
      render address_settings_view
    end
  end

  def edit
    page.load_from_session(session, %i[answer_type answer_settings])
    input_type = @page&.answer_settings&.input_type
    uk_address = input_type&.uk_address
    international_address = input_type&.international_address
    @address_settings_form = Pages::AddressSettingsForm.new(uk_address:, international_address:)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render address_settings_view
  end

  def update
    page
    @address_settings_form = Pages::AddressSettingsForm.new(address_settings_form_params)
    @address_settings_path = address_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @address_settings_form.submit(session)
      redirect_to edit_question_path(@form)
    else
      render address_settings_view
    end
  end

private

  def address_settings_form_params
    params.require(:pages_address_settings_form).permit(:uk_address, :international_address).merge(draft_question:)
  end

  def address_settings_view
    "pages/address_settings"
  end
end
