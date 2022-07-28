class Forms::ChangeEmailForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :submission_email

  EMAIL_REGEX = /.*@.*/
  validates :submission_email, presence: true, format: { with: EMAIL_REGEX, message: :invalid_email }

  def submit
    return false if invalid?

    form.submission_email = submission_email
    form.save!
  end

  def assign_form_values
    self.submission_email = form.submission_email
    self
  end
end
