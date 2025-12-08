require "uri"

class Forms::PaymentLinkInput < BaseInput
  attr_accessor :form, :payment_url

  validates :payment_url, url: true, if: -> { payment_url.present? }
  validates :payment_url, payment_link: true, if: -> { payment_url.present? }

  def submit
    return false if invalid?

    form.payment_url = payment_url
    form.save_draft!
  end

  def assign_form_values
    self.payment_url = form.payment_url
    self
  end
end
