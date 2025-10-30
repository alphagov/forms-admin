require "notifications_utils/recipient_validation/email_address"

class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    NotificationsUtils::RecipientValidation::EmailAddress.validate_email_address(value)
  rescue NotificationsUtils::RecipientValidation::InvalidEmailError
    record.errors.add attribute, (options[:message] || :invalid_email_address)
  end
end
