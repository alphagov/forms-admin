require "rails_helper"

RSpec.describe GroupService do
  subject(:group_service) do
    described_class.new(group:, current_user:, host:)
  end

  let(:group) { create :group }
  let(:current_user) { create :user }
  let(:host) { "example.net" }

  describe "#upgrade_group" do
    let(:group_admin_user1) { create :user }
    let(:group_admin_user2) { create :user }
    let(:editor_user) { create :user }
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
      allow(GroupUpgradeMailer).to receive(:upgraded_email).and_return(delivery)
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
      expect(GroupUpgradeMailer).to have_received(:upgraded_email).with(
        to_email: group_admin_user1.email,
        upgraded_by_name: current_user.name,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
      expect(GroupUpgradeMailer).to have_received(:upgraded_email).with(
        to_email: group_admin_user2.email,
        upgraded_by_name: current_user.name,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
    end

    it "does not send an email to the logged in user that performed the upgrade if they are a group admin" do
      group_service.upgrade_group
      expect(GroupUpgradeMailer).not_to have_received(:upgraded_email).with(
        to_email: current_user.email,
        upgraded_by_name: current_user.name,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
    end
  end

  describe "#reject_upgrade" do
    let(:group_admin_user1) { create :user }
    let(:group_admin_user2) { create :user }
    let(:editor_user) { create :user }
    let(:group) do
      create(:group, status: :upgrade_requested).tap do |group|
        create(:membership, user: group_admin_user1, group:, role: :group_admin)
        create(:membership, user: group_admin_user2, group:, role: :group_admin)
        create(:membership, user: editor_user, group:, role: :editor)
        create(:membership, user: current_user, group:, role: :group_admin)
      end
    end
    let(:delivery) { double }

    before do
      allow(GroupUpgradeMailer).to receive(:rejected_email).and_return(delivery)
      allow(delivery).to receive(:deliver_now).with(no_args)
    end

    it "changes the group status to trial" do
      expect {
        group_service.reject_upgrade
      }.to change(group, :status).to("trial")
    end

    it "sends an email to all group admins" do
      group_service.reject_upgrade
      expect(delivery).to have_received(:deliver_now).with(no_args).exactly(2).times
      expect(GroupUpgradeMailer).to have_received(:rejected_email).with(
        to_email: group_admin_user1.email,
        rejected_by_name: current_user.name,
        rejected_by_email: current_user.email,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
      expect(GroupUpgradeMailer).to have_received(:rejected_email).with(
        to_email: group_admin_user2.email,
        rejected_by_name: current_user.name,
        rejected_by_email: current_user.email,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
    end

    it "does not send an email to the logged in user that rejected the upgrade if they are a group admin" do
      group_service.reject_upgrade
      expect(GroupUpgradeMailer).not_to have_received(:rejected_email).with(
        to_email: current_user.email,
        rejected_by_name: current_user.name,
        rejected_by_email: current_user.email,
        group_name: group.name,
        group_url: group_url(group, host:),
      )
    end
  end

  describe "#request_upgrade" do
    let!(:organisation_admin_user1) { create :organisation_admin_user }
    let!(:organisation_admin_user2) { create :organisation_admin_user }
    let(:editor_user) { create :user }
    let(:group) do
      create(:group).tap do |group|
        create(:membership, user: editor_user, group:, role: :editor)
        create(:membership, user: current_user, group:, role: :group_admin)
      end
    end
    let(:delivery) { double }

    before do
      allow(GroupUpgradeMailer).to receive(:requested_email).and_return(delivery)
      allow(delivery).to receive(:deliver_now).with(no_args)
    end

    it "sets the upgrade_requester on the group" do
      expect {
        group_service.request_upgrade
      }.to change(group, :upgrade_requester).to(current_user)
    end

    it "sets the group status to upgrade_requested" do
      expect {
        group_service.request_upgrade
      }.to change(group, :status).to("upgrade_requested")
    end

    it "sends an email to all organisation admins" do
      expect(GroupUpgradeMailer).to receive(:requested_email).with(
        to_email: organisation_admin_user1.email,
        requester_name: current_user.name,
        requester_email_address: current_user.email,
        group_name: group.name,
        view_request_url: group_url(group, host:),
      )

      expect(GroupUpgradeMailer).to receive(:requested_email).with(
        to_email: organisation_admin_user2.email,
        requester_name: current_user.name,
        requester_email_address: current_user.email,
        group_name: group.name,
        view_request_url: group_url(group, host:),
      )
      group_service.request_upgrade
      expect(delivery).to have_received(:deliver_now).with(no_args).exactly(2).times
    end

    it "does not send an email to a user without the organisation admin role" do
      group_service.request_upgrade
      expect(GroupUpgradeMailer).not_to have_received(:requested_email).with(
        to_email: editor_user.email,
        requester_name: current_user.name,
        requester_email_address: current_user.email,
        group_name: group.name,
        view_request_url: group_url(group, host:),
      )
    end
  end
end
