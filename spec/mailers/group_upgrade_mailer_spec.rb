require "rails_helper"

describe GroupUpgradeMailer, type: :mailer do
  describe "sending an email to a group admin when a group is upgraded" do
    subject(:mail) do
      described_class.group_upgraded_email(upgraded_by_user: current_user, to_email:, group:, group_url:)
    end

    let(:current_user) { create :user }
    let(:group) { create :group }
    let(:to_email) { "email@example.gov.uk" }
    let(:group_url) { "group-dot-com" }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_upgraded_template_id)
    end

    it "sends an email with the correct reply-to value" do
      expect(mail.govuk_notify_email_reply_to).to eq(Settings.govuk_notify.zendesk_reply_to_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end
  end
end
