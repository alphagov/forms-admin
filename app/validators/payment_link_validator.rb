require "uri"
class PaymentLinkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true if payment_url?(value)

    record.errors.add attribute, :url
  end

private

  def payment_url?(value)
    uri = URI(value)
    return true if uri.scheme == "https" && ["www.gov.uk", "gov.uk"].include?(uri.host) && uri.path.starts_with?("/payments/")

    false
  rescue URI::InvalidURIError
    false
  end
end
