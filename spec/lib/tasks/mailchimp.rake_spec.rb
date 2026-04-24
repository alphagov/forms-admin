require "rails_helper"

RSpec.describe "mailchimp.rake", type: :task do
  describe "synchronize_audiences" do
    subject(:task) do
      Rake::Task["mailchimp:synchronize_audiences"]
    end

    it "creates a ListSyncService and calls synchronize_lists" do
      mail_chimp_list_sync_service = instance_double(Mailchimp::ListSyncService)
      allow(Mailchimp::ListSyncService).to receive(:new).and_return(mail_chimp_list_sync_service)
      expect(mail_chimp_list_sync_service).to receive(:synchronize_lists)
      task.invoke
    end
  end
end
