class PaymentLinkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, :url unless value.starts_with?("https://www.gov.uk/payments/", "https://gov.uk/payments/")
    record.errors.add attribute, :url unless value.starts_with?("https://www.gov.uk/payments/", "https://gov.uk/payments/")
  end
end
