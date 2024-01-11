class Pages::CheckYourQuestionController < PagesController
  def show
    render "pages/check_your_question", locals: { current_form:, draft_question: }
  end
end
