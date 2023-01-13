class Forms::TypeOfAnswerForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :answer_type, :form, :page

  validates :answer_type, presence: true, inclusion: { in: Page::ANSWER_TYPES }

  def submit(session)
    return false if invalid?

    session[:page] = { answer_type:, answer_settings: nil }
  end
end
