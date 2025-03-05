require "rails_helper"

RSpec.describe MailchimpListSyncService do
  subject(:mailchimp_list_sync_service) do
    described_class.new
  end

  describe "#synchronize_lists" do
    let(:users_with_access) do
      10.times.map { Faker::Internet.unique.email }
    end

    let(:users_without_access) do
      10.times.map { Faker::Internet.unique.email }
    end

    let(:mou_signer_with_access) { users_with_access.first }

    let(:mou_signer_without_access) { users_without_access.first }

    let(:organisation_admin_with_access) { users_with_access.second }
    let(:mou_signer_and_organisation_admin_with_access) { users_with_access.third }

    before do
      users_with_access.each do |email|
        create :user, email:, has_access: true
      end

      users_without_access.each do |email|
        create :user, email:, has_access: false
      end

      # Create MOU signer with an active user
      create :mou_signature, user: User.where(email: mou_signer_with_access).first

      # Create MOU signer with an inactive user
      create :mou_signature, user: User.where(email: mou_signer_without_access).first

      # Create MOU signer for org admin user
      create :mou_signature, user: User.where(email: mou_signer_and_organisation_admin_with_access).first

      # set organisation admins
      User.find_by(email: organisation_admin_with_access).organisation_admin!
      User.find_by(email: mou_signer_and_organisation_admin_with_access).organisation_admin!
    end

    it "runs the mailchimp synchronization on each list" do
      list_synchronizer = instance_double(MailchimpListSynchronizer)
      allow(MailchimpListSynchronizer).to receive(:new).with(list_id: Settings.mailchimp.active_users_list).and_return(list_synchronizer)
      allow(MailchimpListSynchronizer).to receive(:new).with(list_id: Settings.mailchimp.mou_signers_list).and_return(list_synchronizer)

      expect(list_synchronizer).to receive(:synchronize).with(desired_members: match_array(users_with_access.map { |email| MailchimpMember.new(email: email, status: "subscribed") })).once
      expect(list_synchronizer).to receive(:synchronize).with(desired_members: contain_exactly(MailchimpMember.new(email: mou_signer_with_access, status: "subscribed", role: "Agreed MOU"), MailchimpMember.new(email: organisation_admin_with_access, status: "subscribed", role: "Organisation admin"), MailchimpMember.new(email: mou_signer_and_organisation_admin_with_access, status: "subscribed", role: "Organisation admin agreed MOU"))).once

      expect(Rails.logger).to receive(:debug).with("Synchronizing active users mailing list").once
      expect(Rails.logger).to receive(:debug).with("Synchronizing MOU signers mailing list").once

      mailchimp_list_sync_service.synchronize_lists
    end
  end

  describe "#mou_signers" do
    let(:user_with_access_and_mou) { create(:user, email: "mou_user@example.com") }
    let(:user_with_access_admin) { create(:user, email: "admin_user@example.com") }
    let(:user_without_access) { create(:user, email: "inactive_user@example.com", has_access: false) }
    let(:user_access_and_admin_with_mou) { create(:user, email: "admin_mou_user@example.com") }

    before do
      create(:mou_signature, user: user_with_access_and_mou)
      create(:mou_signature, user: user_access_and_admin_with_mou)
      user_with_access_admin.reload.organisation_admin!
      user_access_and_admin_with_mou.reload.organisation_admin!
    end

    it "returns MOU signers with access and correct roles" do
      expected_members = [
        MailchimpMember.new(email: "mou_user@example.com", status: "subscribed", role: "Agreed MOU"),
        MailchimpMember.new(email: "admin_user@example.com", status: "subscribed", role: "Organisation admin"),
        MailchimpMember.new(email: "admin_mou_user@example.com", status: "subscribed", role: "Organisation admin agreed MOU"),
      ]

      expect(mailchimp_list_sync_service.mou_signers).to match_array(expected_members)
    end

    it "does not include users without access" do
      expect(mailchimp_list_sync_service.mou_signers).not_to include(
        MailchimpMember.new(email: "inactive_user@example.com", status: "subscribed"),
      )
    end
  end
end
