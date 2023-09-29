require "rails_helper"

describe UserUpgradeRequestMailer do
  describe "sending an email to a user" do
    let(:mail) { described_class.upgrade_request_email(user_email: "test@example.gov.uk") }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.user_upgrade_template_id)
    end

    it "sends an email with the correct reply-to value" do
      expect(mail.govuk_notify_email_reply_to).to eq(Settings.govuk_notify.zendesk_reply_to_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq(["test@example.gov.uk"])
    end
  end
end
