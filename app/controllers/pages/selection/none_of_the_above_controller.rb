class Pages::NoneOfTheAboveController < PagesController
  def new
    @none_of_the_above_input = Pages::Selection::NoneOfTheAboveInput.new(
      question_text: draft_question.answer_settings.dig("none_of_the_above", "question_text"),
      is_optional: draft_question.answer_settings.dig("none_of_the_above", "is_optional"),
    )
    @none_of_the_above_page = selection_none_of_the_above_create_path(current_form.id)
    @back_link_url = selection_options_new_path(current_form.id)

    render "pages/selection/none_of_the_above", locals: { current_form: }
  end

  def create
    @none_of_the_above_input = Pages::Select::NoneOfTheAboveInput.new(**input_params)
    @none_of_the_above_page = selection_none_of_the_above_create_path(current_form.id)
    @back_link_url = selection_options_new_path(current_form.id)

    if @none_of_the_above_input.submit
      redirect_to new_question_path(current_form.id)
    else
      render "pages/selection/none_of_the_above", locals: { current_form: }
    end
  end

  def edit
    @none_of_the_above_input = Pages::Selection::NoneOfTheAboveInput.new(
      question_text: draft_question.answer_settings.dig("none_of_the_above", "question_text"),
      is_optional: draft_question.answer_settings.dig("none_of_the_above", "is_optional"),
    )
    @none_of_the_above_page = selection_none_of_the_above_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)

    render "pages/selection/none_of_the_above", locals: { current_form: }
  end

  def update
    @none_of_the_above_input = Pages::Select::NoneOfTheAboveInput.new(**input_params)
    @none_of_the_above_page = selection_none_of_the_above_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)

    if @none_of_the_above_input.submit
      redirect_to edit_question_path(current_form.id)
    else
      render "pages/selection/none_of_the_above", locals: { current_form: }
    end
  end

  def input_params
    params.require(:pages_selection_none_of_the_above)
          .permit(:question_text, :is_optional)
  end
end
