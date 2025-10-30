# frozen_string_literal: true

# This is pretty much a copy of https://github.com/alphagov/notifications-utils/blob/8b39f0006709662df689d52055867bca0a897230/notifications_utils/recipient_validation/email_address.py

require "uri/idna"

require "notifications_utils/formatters"
require "notifications_utils/recipient_validation/errors"

# Valid characters taken from https://en.wikipedia.org/wiki/Email_address#Local-part
# Note: Normal apostrophe eg `Firstname-o'surname@domain.com` is allowed.
# hostname_part regex: xn in regex signifies possible punycode conversions, which would start `xn--`;
# the hyphens are matched for later in the regex.
HOSTNAME_PART = Regexp.compile("^(xn|[a-z0-9]+)(-?-[a-z0-9]+)*$", Regexp::IGNORECASE)
TLD_PART = Regexp.compile("^([a-z]{2,63}|xn--([a-z0-9]+-)*[a-z0-9]+)$", Regexp::IGNORECASE)
VALID_LOCAL_CHARS = "a-zA-Z0-9.!#$%&'*+/=?^_`{|}~\-"
EMAIL_REGEX_PATTERN = /^[#{VALID_LOCAL_CHARS}]+@([^.@][^@\s]+[^.@\s])$/

module NotificationsUtils
  module RecipientValidation
    module EmailAddress
      def validate_email_address(email_address)
        # almost exactly the same as by https://github.com/wtforms/wtforms/blob/master/wtforms/validators.py,
        # with minor tweaks for SES compatibility - to avoid complications we are a lot stricter with the local part
        # than neccessary - we don't allow any double quotes or semicolons to prevent SES Technical Failures
        match = EMAIL_REGEX_PATTERN.match(email_address)

        raise InvalidEmailError unless match

        raise InvalidEmailError if email_address.length > 320

        # don't allow consecutive periods in either part
        raise InvalidEmailError if email_address.include? ".."

        hostname = match[1]
        # idna = "Internationalized domain name" - this encode/decode cycle converts unicode into its accurate ascii
        # representation as the web uses. URI::IDNA.lookup('例え.テスト') == 'xn--r8jz45g.xn--zckzah'
        begin
          hostname = URI::IDNA.lookup hostname.downcase(:ascii)
        rescue URI::IDNA::Error, URI::IDNA::InvalidCodepointError
          raise InvalidEmailError
        end

        parts = hostname.split(".")

        raise InvalidEmailError if hostname.length > 253 || parts.length < 2

        parts.each do |part|
          raise InvalidEmailError if !part || part.length > 63 || !HOSTNAME_PART.match(part)
        end

        # if the part after the last . is not a valid TLD then bail out
        raise InvalidEmailError unless TLD_PART.match(parts[-1])

        email_address
      end

      module_function :validate_email_address
    end
  end
end
