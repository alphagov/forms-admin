require "govuk_forms_markdown"

class DraftQuestion < ApplicationRecord
  include QuestionTextValidation
  include GuidanceValidation

  belongs_to :user

  validates :form_id, presence: true
  validates :hint_text, length: { maximum: 500 }
end
