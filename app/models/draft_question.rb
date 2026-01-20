class DraftQuestion < ApplicationRecord
  belongs_to :user

  validates :form_id, presence: true

  def answer_settings
    raw_settings = read_attribute(:answer_settings)
    return {} if raw_settings.blank?

    raw_settings.deep_symbolize_keys
  end

  delegate :name, to: :form, prefix: true

  def form
    Form.find(form_id)
  end
end
