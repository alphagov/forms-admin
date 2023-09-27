class Pages::AddressSettingsForm < BaseForm
  attr_accessor :uk_address, :international_address, :draft_question

  INPUT_TYPES = %w[uk_address international_address].freeze

  validate :at_least_one_selected?
  validates :uk_address, inclusion: { in: %w[true false] }
  validates :international_address, inclusion: { in: %w[true false] }

  def submit
    return false if invalid?

    draft_question.answer_settings[:input_type] = { uk_address:, international_address: }
    draft_question.save!(validate: false)
  end

  def at_least_one_selected?
    errors.add(:base, :blank) if uk_address == "false" && international_address == "false"
  end
end
