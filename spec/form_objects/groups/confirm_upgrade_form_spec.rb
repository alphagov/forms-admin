require "rails_helper"

RSpec.describe Groups::ConfirmUpgradeForm, type: :model do
  subject(:confirm_upgrade_form) { described_class.new(confirm:, group:, current_user:, host:) }

  let(:confirm) { "yes" }
  let(:group) { create :group }
  let(:current_user) { create :user }
  let(:host) { "example.net" }

  describe "Confirm upgrade form" do
    describe("validations") do
      it "is valid if an option is selected" do
        confirm_upgrade_form.confirm = "yes"
        expect(confirm_upgrade_form).to be_valid
      end

      it "is invalid if blank" do
        confirm_upgrade_form.confirm = ""
        confirm_upgrade_form.validate(:confirm)

        expect(confirm_upgrade_form.errors.full_messages_for(:confirm))
          .to include("Confirm Select yes if you want to upgrade this group")
      end
    end

    describe("#submit") do
      let(:group_admin_user1) { create :user, email: "user1@example.gov.uk" }
      let(:group_admin_user2) { create :user, email: "user2@example.gov.uk" }
      let(:editor_user) { create :user, email: "user3@example.gov.uk" }
      let(:group) do
        create(:group).tap do |group|
          create(:membership, user: group_admin_user1, group:, role: :group_admin)
          create(:membership, user: group_admin_user2, group:, role: :group_admin)
          create(:membership, user: editor_user, group:, role: :editor)
        end
      end
      let(:delivery) { double }

      before do
        allow(GroupUpgradedMailer).to receive(:group_upgraded_email)
                                        .with(upgraded_by_user: current_user, to_email: anything, group:, group_url: group_url(group, host:))
                                        .and_return(delivery)
        allow(delivery).to receive(:deliver_now).with(no_args)
      end

      it "upgrades the group to active" do
        expect {
          confirm_upgrade_form.submit
        }.to change(group, :status).to("active")
      end

      it "sends an email to all group admins" do
        confirm_upgrade_form.submit
        expect(GroupUpgradedMailer).to have_received(:group_upgraded_email).with(upgraded_by_user: current_user, to_email: "user1@example.gov.uk", group:, group_url: group_url(group, host:))
        expect(GroupUpgradedMailer).to have_received(:group_upgraded_email).with(upgraded_by_user: current_user, to_email: "user2@example.gov.uk", group:, group_url: group_url(group, host:))
        expect(delivery).to have_received(:deliver_now).with(no_args).exactly(2).times
      end
    end
  end
end
