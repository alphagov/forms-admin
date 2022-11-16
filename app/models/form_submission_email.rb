class FormSubmissionEmail < ApplicationRecord
  validates :form_id, presence: true

  def confirmed?
    # confirmation_code is blanked when the email code has been confirmed
    confirmation_code.blank?
  end
end
