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
    end

    it "runs the mailchimp synchronization on each list" do
      list_synchronizer = instance_double(MailchimpListSynchronizer)
      allow(MailchimpListSynchronizer).to receive(:new).with(list_id: Settings.mailchimp.active_users_list).and_return(list_synchronizer)
      allow(MailchimpListSynchronizer).to receive(:new).with(list_id: Settings.mailchimp.mou_signers_list).and_return(list_synchronizer)

      expect(list_synchronizer).to receive(:synchronize).with(users_to_synchronize: match_array(users_with_access)).once
      expect(list_synchronizer).to receive(:synchronize).with(users_to_synchronize: [mou_signer_with_access]).once

      expect(Rails.logger).to receive(:debug).with("Synchronizing active users mailing list").once
      expect(Rails.logger).to receive(:debug).with("Synchronizing MOU signers mailing list").once

      mailchimp_list_sync_service.synchronize_lists
    end
  end
end
