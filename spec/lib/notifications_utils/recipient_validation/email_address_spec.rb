# frozen_string_literal: true

require "spec_helper"
require "./spec/support/custom_matchers"

require "notifications_utils/recipient_validation/email_address"

RSpec.describe NotificationsUtils::RecipientValidation::EmailAddress do
  [
    "email@domain.com",
    "email@domain.COM",
    "firstname.lastname@domain.com",
    "firstname.o'lastname@domain.com",
    "email@subdomain.domain.com",
    "firstname+lastname@domain.com",
    "1234567890@domain.com",
    "email@domain-one.com",
    "_______@domain.com",
    "email@domain.name",
    "email@domain.superlongtld",
    "email@domain.co.jp",
    "firstname-lastname@domain.com",
    "info@german-financial-services.vermögensberatung",
    "info@german-financial-services.reallylongarbitrarytldthatiswaytoohugejustincase",
    "japanese-info@例え.テスト",
    "email@double--hyphen.com",
  ].each do |valid_email_address|
    context "with #{valid_email_address.dump}" do
      it "accepts valid email address" do
        expect(described_class.validate_email_address(valid_email_address)).to be_truthy
      end
    end
  end

  [
    "email@***************",
    "email@[***************]",
    "plainaddress",
    "@no-local-part.com",
    "Outlook Contact <outlook-contact@domain.com>",
    "no-at.domain.com",
    "no-tld@domain",
    ";beginning-semicolon@domain.co.uk",
    "middle-semicolon@domain.co;uk",
    "trailing-semicolon@domain.com;",
    '"email+leading-quotes@domain.com',
    'email+middle"-quotes@domain.com',
    '"quoted-local-part"@domain.com',
    '"quoted@domain.com"',
    "lots-of-dots@domain..gov..uk",
    "two-dots..in-local@domain.com",
    "dot-at-end@domain.com.",
    "multiple@domains@domain.com",
    "spaces in local@domain.com",
    "spaces-in-domain@dom ain.com",
    "underscores-in-domain@dom_ain.com",
    "pipe-in-domain@example.com|gov.uk",
    "comma,in-local@gov.uk",
    "comma-in-domain@domain,gov.uk",
    "pound-sign-in-local£@domain.com",
    "local-with-\u2018-apostrophe@domain.com",
    "local-with-\u201c-quotes@domain.com",
    "domain-starts-with-a-dot@.domain.com",
    "brackets(in)local@domain.com",
    "email-too-long-#{'a' * 320}@example.com",
    "incorrect-punycode@xn---something.com",
    " email@domain.com ",
    "\temail@domain.com",
    "\temail@domain.com\n",
    "\u200bemail@domain.com\u200b",
  ].each do |invalid_email_address|
    context "with #{invalid_email_address.dump}" do
      it "raises for invalid email address" do
        expect {
          described_class.validate_email_address(invalid_email_address)
        }.to raise_error NotificationsUtils::RecipientValidation::InvalidEmailError, "Not a valid email address"
      end
    end
  end
end
