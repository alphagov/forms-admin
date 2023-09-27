require "govuk_forms_markdown"

class DraftQuestion < ApplicationRecord
  include QuestionTextValidation
  include GuidanceValidation

  belongs_to :user

  validates :form_id, presence: true
  validates :hint_text, length: { maximum: 500 }
  serialize :answer_settings, JsonbSerializers

  def show_selection_options
    answer_settings[:selection_options].map { |option| option["name"] }.join(", ")
  end
end
