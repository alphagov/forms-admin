class Pages::NameSettingsController < PagesController
  def new
    @name_settings_form = Pages::NameSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render name_settings_view
  end

  def create
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @name_settings_form.submit
      redirect_to new_page_path(@form)
    else
      render name_settings_view
    end
  end

  def edit
    @name_settings_form = Pages::NameSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render name_settings_view
  end

  def update
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @name_settings_form.submit
      redirect_to edit_page_path(@form)
    else
      render name_settings_view
    end
  end

private

  def name_settings_form_params
    params.require(:pages_name_settings_form).permit(:input_type, :title_needed).merge(draft_question:)
  end

  def name_settings_view
    "pages/name_settings"
  end
end
