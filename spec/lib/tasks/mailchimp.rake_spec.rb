require "rake"

require "rails_helper"

RSpec.describe "mailchimp.rake" do
  describe "synchronize_audiences" do
    subject(:task) do
      Rake::Task["mailchimp:synchronize_audiences"]
        .tap(&:reenable)
    end

    before do
      Rake.application.rake_require "tasks/mailchimp"
      Rake::Task.define_task(:environment)
    end

    it "creates MailchimpListSyncService and calls synchronize_lists" do
      mail_chimp_list_sync_service = instance_double(MailchimpListSyncService)
      allow(MailchimpListSyncService).to receive(:new).and_return(mail_chimp_list_sync_service)
      expect(mail_chimp_list_sync_service).to receive(:synchronize_lists)
      task.invoke
    end
  end
end
