class Pages::NameSettingsController < PagesController
  def new
    @name_settings_input = Pages::NameSettingsInput.new(input_type: draft_question.answer_settings[:input_type],
                                                        title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)
    render :name_settings, locals: { current_form: }
  end

  def create
    @name_settings_input = Pages::NameSettingsInput.new(name_settings_input_params)
    @name_settings_path = name_settings_create_path(current_form.id)
    @back_link_url = type_of_answer_new_path(current_form.id)

    if @name_settings_input.submit
      redirect_to new_question_path(current_form.id)
    else
      render :name_settings, locals: { current_form: }
    end
  end

  def edit
    @name_settings_input = Pages::NameSettingsInput.new(input_type: draft_question.answer_settings[:input_type],
                                                        title_needed: draft_question.answer_settings[:title_needed])
    @name_settings_path = name_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)
    render :name_settings, locals: { current_form: }
  end

  def update
    @name_settings_input = Pages::NameSettingsInput.new(name_settings_input_params)
    @name_settings_path = name_settings_update_path(current_form.id)
    @back_link_url = type_of_answer_edit_path(current_form.id)

    if @name_settings_input.submit
      redirect_to edit_question_path(current_form.id)
    else
      page
      render :name_settings, locals: { current_form: }
    end
  end

private

  def name_settings_input_params
    params.require(:pages_name_settings_input).permit(:input_type, :title_needed).merge(draft_question:)
  end
end
