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
    end

    it "runs the mailchimp synchronization on each list" do
      expect(MailchimpListSynchronizer).to receive(:synchronize).with(list_id: "list-1", users_to_synchronize: users_with_access).once
      expect(MailchimpListSynchronizer).to receive(:synchronize).with(list_id: "list-2", users_to_synchronize: users_with_access).once

      expect { task.invoke }.to output.to_stdout
    end
  end
end
