# frozen_string_literal: true

# Copy of just the bits we need from https://github.com/alphagov/notifications-utils/blob/8b39f0006709662df689d52055867bca0a897230/notifications_utils/recipient_validation/errors.py

module NotificationsUtils
  module RecipientValidation
    class InvalidRecipientError < StandardError
      def message
        "Not a valid recipient address"
      end
    end

    class InvalidEmailError < StandardError
      def message
        "Not a valid email address"
      end
    end
  end
end
