class FormSubmissionEmail < ApplicationRecord
  validates :form_id, presence: true
  validates :temporary_submission_email, email_address: { message: :invalid_email }, allow_blank: true

  def confirmed?
    # confirmation_code is blanked when the email code has been confirmed
    confirmation_code.blank?
  end
end
