class Pages::NameSettingsController < PagesController
  def new
    @name_settings_form = Pages::NameSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :name_settings, locals: { current_form: }
  end

  def create
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @name_settings_form.submit
      redirect_to new_question_path(current_form)
    else
      render :name_settings, locals: { current_form: }
    end
  end

  def edit
    @name_settings_form = Pages::NameSettingsForm.new(input_type: draft_question.answer_settings[:input_type],
                                                      title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)
    render :name_settings, locals: { current_form: }
  end

  def update
    @name_settings_form = Pages::NameSettingsForm.new(name_settings_form_params)
    @name_settings_path = name_settings_update_path(current_form)
    @back_link_url = type_of_answer_edit_path(current_form)

    if @name_settings_form.submit
      redirect_to edit_question_path(current_form)
    else
      page
      render :name_settings, locals: { current_form: }
    end
  end

private

  def name_settings_form_params
    params.require(:pages_name_settings_form).permit(:input_type, :title_needed).merge(draft_question:)
  end
end
