class Forms::AddressSettingsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :uk_address, :international_address, :form, :page, :input_type

  INPUT_TYPES = %w[uk_address international_address].freeze

  # validate :any_present?
  # validates :input_type, presence: true
  validates :uk_address, inclusion: { in: %w[true false] }
  # validates :international_address, inclusion: { in: %w[true false] }

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type: { uk_address:, international_address: } }
  end

  def assign_values_to_page(page)
    return false if invalid?

    page.answer_settings = { input_type: { uk_address:, international_address: } }
  end

  def any_present?
    return errors.add(:uk_address, :blank) if uk_address == "false" && international_address == "false"
  end
end
