class Forms::TypeOfAnswerForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :answer_type, :form

  validates :answer_type, presence: true

  def submit(session)
    return false if invalid?

    session[:page] = { answer_type: }
  end

  def number(form)
    # If this page is in form, return the position, else it must be new so
    # return the number if it was inserted at the end
    index = form.pages.index(self)
    (index.nil? ? form.pages.length : index) + 1
  end
end
