class FormSubmissionEmail < ApplicationRecord
  validates :form_id, presence: true
end
