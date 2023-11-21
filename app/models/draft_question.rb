require "govuk_forms_markdown"

class DraftQuestion < ApplicationRecord
  include QuestionTextValidation
  include GuidanceValidation

  belongs_to :user

  validates :form_id, presence: true
  validates :hint_text, length: { maximum: 500 }

  def answer_settings
    raw_settings = read_attribute(:answer_settings)
    return raw_settings if raw_settings.blank?

    raw_settings.deep_symbolize_keys
  end
end
