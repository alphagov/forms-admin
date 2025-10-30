require "rails_helper"

describe GroupDeleteMailer, type: :mailer do
  let(:current_user) { create :organisation_admin_user }
  let(:group) { create :group }
  let(:to_email) { "email@example.gov.uk" }

  describe "#group_deleted_email" do
    context "when user is an org admin" do
      subject(:mail) do
        described_class.group_deleted_email_org_admin(
          to_email:,
          group_name: group.name,
          org_admin_email_address: current_user.email,
          org_admin_name: current_user.name,
        )
      end

      it "sends an email with the correct template" do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_deleted_org_admin_template_id)
      end

      it "includes the personalisation" do
        expect(mail.govuk_notify_personalisation[:group_name]).to eq(group.name)
        expect(mail.govuk_notify_personalisation[:org_admin_email_address]).to eq(current_user.email)
        expect(mail.govuk_notify_personalisation[:org_admin_name]).to eq(current_user.name)
      end
    end

    context "when users is a group admin" do
      subject(:mail) do
        described_class.group_deleted_email_group_admins_and_editors(
          to_email:,
          group_name: group.name,
          org_admin_email_address: current_user.email,
          org_admin_name: current_user.name,
        )
      end

      it "sends an email with the correct template" do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_deleted_group_admin_editor_template_id)
      end

      it "includes the personalisation" do
        expect(mail.govuk_notify_personalisation[:group_name]).to eq(group.name)
        expect(mail.govuk_notify_personalisation[:org_admin_email_address]).to eq(current_user.email)
        expect(mail.govuk_notify_personalisation[:org_admin_name]).to eq(current_user.name)
      end
    end
  end
end
