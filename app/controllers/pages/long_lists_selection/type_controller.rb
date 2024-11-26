class Pages::LongListsSelection::TypeController < PagesController
  include PagesHelper
  def new
    @selection_type_input = Pages::Selection::TypeInput.new(only_one_option:, draft_question:)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)
    render "pages/long_lists_selection/type", locals: { current_form: }
  end

  def create
    @selection_type_input = Pages::Selection::TypeInput.new(type_params)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)

    if @selection_type_input.submit
      redirect_to selection_options_new_path_for_draft_question(draft_question)
    else
      render "pages/long_lists_selection/type", locals: { current_form: }
    end
  end

  def edit
    @selection_type_input = Pages::Selection::TypeInput.new(only_one_option:, draft_question:)
    @selection_type_path = long_lists_selection_type_update_path(current_form)
    @back_link_url = edit_question_path(current_form)
    render "pages/long_lists_selection/type", locals: { current_form: }
  end

  def update
    @selection_type_input = Pages::Selection::TypeInput.new(type_params)
    @selection_type_path = long_lists_selection_type_create_path(current_form)
    @back_link_url = edit_question_path(current_form)

    if @selection_type_input.submit
      redirect_to selection_options_edit_path_for_draft_question(draft_question)
    else
      render "pages/long_lists_selection/type", locals: { current_form: }
    end
  end

private

  def type_params
    params.require(:pages_selection_type_input)
          .permit(:only_one_option)
          .merge(draft_question:)
  end

  def only_one_option
    only_one_option = draft_question.answer_settings[:only_one_option]
    # This ensures there is backwards compatibility for existing questions as we previously set "only_one_option" to
    # "0" rather than "false"
    return "false" if only_one_option == "0"

    only_one_option
  end
end
