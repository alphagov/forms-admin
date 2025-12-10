class Pages::Selection::NoneOfTheAboveController < PagesController
  include PagesHelper

  def new
    @none_of_the_above_input = input_object_from_draft_question
    @none_of_the_above_path = selection_none_of_the_above_create_path(current_form.id)
    @back_link_url = selection_options_new_path_for_draft_question(draft_question)

    render "pages/selection/none_of_the_above", locals: { current_form: }
  end

  def create
    @none_of_the_above_input = Pages::Selection::NoneOfTheAboveInput.new(**input_params, draft_question:)
    @none_of_the_above_path = selection_none_of_the_above_create_path(current_form.id)
    @back_link_url = selection_options_new_path_for_draft_question(draft_question)

    if @none_of_the_above_input.submit
      redirect_to new_question_path(current_form.id)
    else
      render "pages/selection/none_of_the_above", locals: { current_form: }
    end
  end

  def edit
    @none_of_the_above_input = input_object_from_draft_question
    @none_of_the_above_path = selection_none_of_the_above_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)

    render "pages/selection/none_of_the_above", locals: { current_form: }
  end

  def update
    @none_of_the_above_input = Pages::Selection::NoneOfTheAboveInput.new(**input_params, draft_question:)
    @none_of_the_above_path = selection_none_of_the_above_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)

    if @none_of_the_above_input.submit
      redirect_to edit_question_path(current_form.id)
    else
      render "pages/selection/none_of_the_above", locals: { current_form: }
    end
  end

private

  def input_object_from_draft_question
    Pages::Selection::NoneOfTheAboveInput.new(
      question_text: draft_question.answer_settings.dig(:none_of_the_above_question, :question_text),
      is_optional: draft_question.answer_settings.dig(:none_of_the_above_question, :is_optional),
      draft_question:,
    )
  end

  def input_params
    params.require(:pages_selection_none_of_the_above_input)
          .permit(:question_text, :is_optional)
  end
end
