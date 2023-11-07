class Pages::NameSettingsController < PagesController
  def new
    input_type = session.dig(:page, :answer_settings, :input_type)
    title_needed = session.dig(:page, :answer_settings, :title_needed)
    @name_settings_form = Pages::NameSettingsForm.new(input_type:, title_needed:)
    @name_settings_path = name_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :name_settings, locals: { current_form: }
  end

  def create
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @name_settings_form.submit(session)
      redirect_to new_question_path(current_form)
    else
      render :name_settings, locals: { current_form: }
    end
  end

  def edit
    page.load_from_session(session, %i[answer_settings])
    input_type = @page.answer_settings&.input_type
    title_needed = @page.answer_settings&.title_needed
    @name_settings_form = Pages::NameSettingsForm.new(input_type:, title_needed:)
    @name_settings_path = name_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :name_settings, locals: { current_form: }
  end

  def update
    page
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @name_settings_form.submit(session)
      redirect_to edit_question_path(current_form)
    else
      render :name_settings, locals: { current_form: }
    end
  end

private

  def name_settings_form_params
    params.require(:pages_name_settings_form).permit(:input_type, :title_needed).merge(draft_question:)
  end
end
