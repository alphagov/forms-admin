class Pages::LongListsSelection::TypeController < PagesController
  def new
    @selection_type_input = Pages::LongListsSelection::TypeInput.new(only_one_option:, draft_question:)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)
    render "pages/long_lists_selection/type", locals: { current_form: }
  end

  def create
    @selection_type_input = Pages::LongListsSelection::TypeInput.new(type_params)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)

    if @selection_type_input.submit
      redirect_to long_lists_selection_options_new_path
    else
      render "pages/long_lists_selection/type", locals: { current_form: }
    end
  end

  def edit
    @selection_type_input = Pages::LongListsSelection::TypeInput.new(only_one_option:, draft_question:)
    @selection_type_path = long_lists_selection_type_update_path(current_form)
    @back_link_url = edit_question_path(current_form)
    render "pages/long_lists_selection/type", locals: { current_form: }
  end

  def update
    @selection_type_input = Pages::LongListsSelection::TypeInput.new(type_params)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = edit_question_path(current_form)

    if @selection_type_input.submit
      redirect_to long_lists_selection_options_edit_path
    else
      render "pages/long_lists_selection/type", locals: { current_form: }
    end
  end

private

  def type_params
    params.require(:pages_long_lists_selection_type_input)
          .permit(:only_one_option)
          .merge(draft_question:)
  end

  def only_one_option
    draft_question.answer_settings[:only_one_option]
  end
end
