class Forms::ConfirmEmailForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :email_code

  EMAIL_CODE_REGEX = /[0-9]{6}/
  validates :email_code, presence: true
  validates :email_code, format: { with: EMAIL_CODE_REGEX, message: :invalid_email_code }, if: -> { email_code.present? }

  def submit
    return false if invalid?

    # Add validation to check the code is correct
    # set email here
    true
  end
end
