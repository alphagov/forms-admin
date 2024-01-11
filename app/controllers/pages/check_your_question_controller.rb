class Pages::CheckYourQuestionController < PagesController
  def show
    @back_link_url = new_question_path(current_form)
    render "pages/check_your_question", locals: { current_form:, draft_question: }
  end
end
