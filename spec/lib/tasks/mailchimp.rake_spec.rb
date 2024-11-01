require "rake"

require "rails_helper"

RSpec.describe "mailchimp.rake" do
  describe "synchronize_audiences" do
    subject(:task) do
      Rake::Task["mailchimp:synchronize_audiences"]
        .tap(&:reenable)
    end

    let(:users_with_access) do
      10.times.map { Faker::Internet.unique.email }
    end

    let(:users_without_access) do
      10.times.map { Faker::Internet.unique.email }
    end

    let(:mou_signer_with_access) { users_with_access.first }

    let(:mou_signer_without_access) { users_without_access.first }

    before do
      # Rake.application.options.trace = true

      Rake.application.rake_require "tasks/mailchimp"
      Rake::Task.define_task(:environment)

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
      expect(MailchimpListSynchronizer).to receive(:synchronize).with(list_id: Settings.mailchimp.active_users_list, users_to_synchronize: match_array(users_with_access)).once
      expect(MailchimpListSynchronizer).to receive(:synchronize).with(list_id: Settings.mailchimp.mou_signers_list, users_to_synchronize: [mou_signer_with_access]).once

      expect { task.invoke }.to output.to_stdout
    end
  end
end
