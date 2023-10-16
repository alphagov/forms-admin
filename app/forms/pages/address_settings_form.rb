class Pages::AddressSettingsForm < BaseForm
  attr_accessor :uk_address, :international_address, :draft_question

  INPUT_TYPES = %w[uk_address international_address].freeze

  validates :draft_question, presence: true
  validate :at_least_one_selected?
  validates :uk_address, inclusion: { in: %w[true false] }
  validates :international_address, inclusion: { in: %w[true false] }

  def submit(session)
    return false if invalid?

    # Set the answer_settings hash
    answer_settings = {
      input_type: {
        uk_address: uk_address.to_s,
        international_address: international_address.to_s,
      },
    }

    # Set answer_settings for the draft_question
    draft_question.answer_settings = answer_settings.with_indifferent_access
    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = answer_settings
  end

  def at_least_one_selected?
    errors.add(:base, :blank) if uk_address == "false" && international_address == "false"
  end
end
