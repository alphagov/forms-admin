require "uri"

class Forms::PaymentLinkForm < BaseForm
  attr_accessor :form, :payment_url

  validates :payment_url, url: true, if: -> { payment_url.present? }
  validate :is_pay_url?, if: -> { payment_url.present? }

  def submit
    return false if invalid?

    form.payment_url = payment_url
    form.save!
  end

  def assign_form_values
    self.payment_url = form.payment_url
    self
  end

  def is_pay_url?
    errors.add :payment_url, :url unless payment_url.starts_with?("https://www.gov.uk/payments/")
  end
end
