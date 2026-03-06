require "rails_helper"

describe OrgAdminAlerts::MadeLiveMailer, type: :mailer do
  let(:form) { create :form, :live }
  let(:user) { create :user }
  let(:to_email) { "admin@example.gov.uk" }

  describe "#new_draft_form_made_live" do
    subject(:mail) do
      described_class.new_draft_form_made_live(
        form:,
        user:,
        to_email:,
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.org_admin_alerts.new_draft_form_made_live_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq(form.name)
      expect(mail.govuk_notify_personalisation[:form_link]).to eq(live_form_url(form))
      expect(mail.govuk_notify_personalisation[:user_name]).to eq(user.name)
      expect(mail.govuk_notify_personalisation[:user_email]).to eq(user.email)
    end
  end

  describe "#live_form_changes_made_live" do
    subject(:mail) do
      described_class.live_form_changes_made_live(
        form:,
        user:,
        to_email:,
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.org_admin_alerts.live_form_changes_made_live_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq(form.name)
      expect(mail.govuk_notify_personalisation[:form_link]).to eq(live_form_url(form))
      expect(mail.govuk_notify_personalisation[:user_name]).to eq(user.name)
      expect(mail.govuk_notify_personalisation[:user_email]).to eq(user.email)
    end
  end

  describe "#archived_form_changes_made_live" do
    subject(:mail) do
      described_class.archived_form_changes_made_live(
        form:,
        user:,
        to_email:,
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.org_admin_alerts.archived_form_changes_made_live_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq(form.name)
      expect(mail.govuk_notify_personalisation[:form_link]).to eq(live_form_url(form))
      expect(mail.govuk_notify_personalisation[:user_name]).to eq(user.name)
      expect(mail.govuk_notify_personalisation[:user_email]).to eq(user.email)
    end
  end

  describe "#copied_form_made_live" do
    subject(:mail) do
      described_class.copied_form_made_live(
        form:,
        copied_from_form:,
        user:,
        to_email:,
      )
    end

    let(:copied_from_form) { create :form }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.org_admin_alerts.copied_form_made_live_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq(form.name)
      expect(mail.govuk_notify_personalisation[:form_link]).to eq(live_form_url(form))
      expect(mail.govuk_notify_personalisation[:copied_from_form_name]).to eq(copied_from_form.name)
      expect(mail.govuk_notify_personalisation[:copied_from_form_link]).to eq(form_url(copied_from_form))
      expect(mail.govuk_notify_personalisation[:user_name]).to eq(user.name)
      expect(mail.govuk_notify_personalisation[:user_email]).to eq(user.email)
    end
  end

  describe "#archived_form_made_live" do
    subject(:mail) do
      described_class.archived_form_made_live(
        form:,
        user:,
        to_email:,
      )
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.org_admin_alerts.archived_form_made_live_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([to_email])
    end

    it "includes the personalisation" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq(form.name)
      expect(mail.govuk_notify_personalisation[:form_link]).to eq(live_form_url(form))
      expect(mail.govuk_notify_personalisation[:user_name]).to eq(user.name)
      expect(mail.govuk_notify_personalisation[:user_email]).to eq(user.email)
    end
  end
end
