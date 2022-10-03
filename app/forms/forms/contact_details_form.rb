class Forms::ContactDetailsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :email, :phone, :link_text, :link_href, :contact_details_supplied

  EMAIL_REGEX = /.*@.*/
  GOVUK_EMAIL_REGEX = /\.gov\.uk\z/

  validates :email, presence: true, format: { with: EMAIL_REGEX, message: :invalid_email }, if: -> { supplied :supply_email }
  validates :email, format: { with: GOVUK_EMAIL_REGEX, message: :non_govuk_email }, if: -> { supplied :supply_email }
  validates :phone, presence: true, length: { maximum: 500 }, if: -> { supplied :supply_phone }
  validates :link_href, presence: true, url: true, length: { maximum: 120 }, if: -> { supplied :supply_link }
  validates :link_text, presence: true, length: { maximum: 120 }, if: -> { supplied :supply_link }

  validates :contact_details_supplied, length: { minimum: 2 }

  def initialize(attrs = {})
    attrs.deep_symbolize_keys!

    super(attrs)

    # Update the values for the checkboxes, so they are shown ticked in error
    # state
    @contact_details_supplied = []
    @contact_details_supplied = attrs[:contact_details_supplied].compact.map(&:to_sym) if attrs.key?(:contact_details_supplied)
  end

  def submit
    form.support_email = nil
    form.support_phone = nil
    form.support_url = nil
    form.support_url_text = nil

    return false if invalid?

    form.support_email = email if supplied(:supply_email)
    form.support_phone = phone if supplied(:supply_phone)
    form.support_url = link_href if supplied(:supply_link)
    form.support_url_text = link_text if supplied(:supply_link)

    form.save!
  end

  def assign_form_values
    self.contact_details_supplied |= [:supply_email] if form.support_email.present?
    self.contact_details_supplied |= [:supply_phone] if form.support_phone.present?
    self.contact_details_supplied |= [:supply_link] if form.support_url.present?

    self.email = form.support_email
    self.phone = form.support_phone
    self.link_href = form.support_url
    self.link_text = form.support_url_text

    self
  end

  def check_email?
    email.present? || supplied(:supply_email)
  end

  def check_phone?
    phone.present? || supplied(:supply_phone)
  end

  def check_link?
    link_href.present? || supplied(:supply_link)
  end

private

  def supplied(field)
    contact_details_supplied.map(&:to_sym).include? field
  end
end
