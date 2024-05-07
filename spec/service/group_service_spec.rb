require "rails_helper"

RSpec.describe GroupService do
  subject(:group_service) do
    described_class.new(group:, current_user:, host:)
  end

  let(:group) { create :group }
  let(:current_user) { create :user, email: "current_user@example.gov.uk" }
  let(:host) { "example.net" }

  describe "#upgrade_group" do
    let(:group_admin_user1) { create :user, email: "user1@example.gov.uk" }
    let(:group_admin_user2) { create :user, email: "user2@example.gov.uk" }
    let(:editor_user) { create :user, email: "user3@example.gov.uk" }
    let(:group) do
      create(:group).tap do |group|
        create(:membership, user: group_admin_user1, group:, role: :group_admin)
        create(:membership, user: group_admin_user2, group:, role: :group_admin)
        create(:membership, user: editor_user, group:, role: :editor)
        create(:membership, user: current_user, group:, role: :group_admin)
      end
    end
    let(:delivery) { double }

    before do
      allow(GroupUpgradeMailer).to receive(:group_upgraded_email).and_return(delivery)
      allow(delivery).to receive(:deliver_now).with(no_args)
    end

    it "upgrades the group to active" do
      expect {
        group_service.upgrade_group
      }.to change(group, :status).to("active")
    end

    it "sends an email to all group admins" do
      group_service.upgrade_group
      expect(delivery).to have_received(:deliver_now).with(no_args).exactly(2).times
      expect(GroupUpgradeMailer).to have_received(:group_upgraded_email).with(upgraded_by_name: current_user.name, to_email: "user1@example.gov.uk", group_name: group.name, group_url: group_url(group, host:))
      expect(GroupUpgradeMailer).to have_received(:group_upgraded_email).with(upgraded_by_name: current_user.name, to_email: "user2@example.gov.uk", group_name: group.name, group_url: group_url(group, host:))
    end

    it "does not send an email to the logged in user that performed the upgrade if they are a group admin" do
      group_service.upgrade_group
      expect(GroupUpgradeMailer).not_to have_received(:group_upgraded_email).with(upgraded_by_name: current_user.name, to_email: current_user.email, group_name: group.name, group_url: group_url(group, host:))
    end
  end
end
