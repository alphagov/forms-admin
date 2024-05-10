require "rails_helper"

describe GroupUpgradeMailer, type: :mailer do
  let(:current_user) { create :user }
  let(:group) { create :group }
  let(:to_email) { "email@example.gov.uk" }
  let(:group_url) { "group-dot-com" }

  describe "#group_upgraded_email" do
    subject(:mail) do
      described_class.group_upgraded_email(
        upgraded_by_name: current_user.name,
        to_email:,
        group_name: group.name,
        group_url:,
      )
    end

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

  describe "#rejected_email" do
    subject(:mail) do
      described_class.rejected_email(
        to_email:,
        rejected_by_name: current_user.name,
        rejected_by_email: current_user.email,
        group_name: group.name,
        group_url:,
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_upgrade_rejected_template_id)
    end

    it "sends an email with the correct reply-to value" do
      expect(mail.govuk_notify_email_reply_to).to eq(Settings.govuk_notify.zendesk_reply_to_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:rejected_by_name]).to eq(current_user.name)
      expect(mail.govuk_notify_personalisation[:rejected_by_email]).to eq(current_user.email)
      expect(mail.govuk_notify_personalisation[:group_name]).to eq(group.name)
      expect(mail.govuk_notify_personalisation[:group_url]).to eq(group_url)
    end
  end

  describe "#group_upgrade_requested_email" do
    subject(:mail) do
      described_class.group_upgrade_requested_email(
        requester_name: current_user.name,
        requester_email_address: current_user.email,
        to_email:, group_name: group.name,
        view_request_url: group_url
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_upgrade_requested_template_id)
    end

    it "sends an email with the correct reply-to value" do
      expect(mail.govuk_notify_email_reply_to).to eq(Settings.govuk_notify.zendesk_reply_to_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:requester_name]).to eq(current_user.name)
      expect(mail.govuk_notify_personalisation[:requester_email_address]).to eq(current_user.email)
      expect(mail.govuk_notify_personalisation[:group_name]).to eq(group.name)
      expect(mail.govuk_notify_personalisation[:view_request_url]).to eq(group_url)
    end
  end
end
