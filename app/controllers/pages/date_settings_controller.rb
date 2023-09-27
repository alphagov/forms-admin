class Pages::DateSettingsController < PagesController
  def new
    @date_settings_form = Pages::DateSettingsForm.new(input_type: draft_question.answer_settings[:input_type])
    @date_settings_path = date_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/date_settings"
  end

  def create
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @date_settings_form.submit
      redirect_to new_page_path(@form)
    else
      render "pages/date_settings"
    end
  end

  def edit
    @date_settings_form = Pages::DateSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      draft_question:)
    @date_settings_path = date_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)
    render "pages/date_settings"
  end

  def update
    page
    @date_settings_form = Pages::DateSettingsForm.new(date_settings_form_params)
    @date_settings_path = date_settings_update_path(@form)
    @back_link_url = type_of_answer_edit_path(@form)

    if @date_settings_form.submit
      redirect_to edit_page_path(@form)
    else
      render "pages/date_settings"
    end
  end

private

  def date_settings_form_params
    params.require(:pages_date_settings_form).permit(:input_type).merge(draft_question:)
  end
end
