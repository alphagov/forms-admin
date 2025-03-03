namespace :mailchimp do
  desc "Synchronise Mailchimp audiences with the users in the database"
  task synchronize_audiences: :environment do
    MailchimpListSyncService.new.synchronize_lists
  end
end
