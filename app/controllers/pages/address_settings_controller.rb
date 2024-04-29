class Pages::AddressSettingsController < PagesController
  def new
    settings = draft_question.answer_settings
    @address_settings_input = Pages::AddressSettingsInput.new(uk_address: settings.dig(:input_type, :uk_address),
                                                              international_address: settings.dig(:input_type, :international_address))
    @address_settings_path = address_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :address_settings, locals: { current_form: }
  end

  def create
    @address_settings_input = Pages::AddressSettingsInput.new(address_settings_input_params)
    @address_settings_path = address_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @address_settings_input.submit
      redirect_to new_question_path(current_form)
    else
      render :address_settings, locals: { current_form: }
    end
  end

  def edit
    settings = draft_question.answer_settings
    @address_settings_input = Pages::AddressSettingsInput.new(uk_address: settings.dig(:input_type, :uk_address),
                                                              international_address: settings.dig(:input_type, :international_address))
    @address_settings_path = address_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :address_settings, locals: { current_form: }
  end

  def update
    @address_settings_input = Pages::AddressSettingsInput.new(address_settings_input_params)
    @address_settings_path = address_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @address_settings_input.submit
      redirect_to edit_question_path(current_form)
    else
      page
      render :address_settings, locals: { current_form: }
    end
  end

private

  def address_settings_input_params
    params.require(:pages_address_settings_input).permit(:uk_address, :international_address).merge(draft_question:)
  end
end
