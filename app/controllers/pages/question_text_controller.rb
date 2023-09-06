class Pages::QuestionTextController < PagesController
  def new
    question_text = session.dig(:page, "question_text")
    @question_text_form = Pages::QuestionTextForm.new(question_text:)
    @question_text_path = question_text_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render "pages/question_text"
  end

  def create
    @question_text_form = Pages::QuestionTextForm.new(question_text_form_params)
    @question_text_path = question_text_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if @question_text_form.submit(session)
      redirect_to selections_settings_new_path(@form)
    else
      render "pages/question_text"
    end
  end

private

  def question_text_form_params
    params.require(:pages_question_text_form).permit(:question_text)
  end
end
