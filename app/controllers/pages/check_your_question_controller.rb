class Pages::CheckYourQuestionController < PagesController
  def show
    render "pages/check_your_question", locals: { current_form: }
  end
end
