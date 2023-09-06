class Pages::QuestionTextForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:question_text] = question_text
  end
end
