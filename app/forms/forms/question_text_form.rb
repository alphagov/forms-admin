class Forms::QuestionTextForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :question_text

  validates :question_text, presence: true

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:question_text] = question_text
  end
end
