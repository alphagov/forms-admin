class Pages::QuestionTextController < PagesController
  def new
    @question_text_input = Pages::QuestionTextInput.new(question_text: draft_question.question_text)
    @question_text_path = question_text_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)
    render :question_text, locals: { current_form: }
  end

  def create
    @question_text_input = Pages::QuestionTextInput.new(question_text_input_params)
    @question_text_path = question_text_create_path(current_form)
    @back_link_url = type_of_answer_new_path(current_form)

    if @question_text_input.submit
      redirect_to long_lists_selection_type_new_path(current_form)
    else
      render :question_text, locals: { current_form: }
    end
  end

private

  def question_text_input_params
    params.require(:pages_question_text_input).permit(:question_text).merge(draft_question:)
  end
end
