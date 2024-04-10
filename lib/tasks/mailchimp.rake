namespace :mailchimp do
  desc "Synchronise Mailchimp audiences with the users in the database"
  task synchronize_audiences: :environment do
    mailchimp_lists = Settings.mailchimp.lists

    puts "Mailchimp lists: #{mailchimp_lists}"

    db_email_addresses = User.where(has_access: true).pluck(:email)

    puts "There are #{mailchimp_lists.length} lists to synchronize"
    mailchimp_lists.each do |list_id|
      MailchimpListSynchronizer.synchronize(list_id:, users_to_synchronize: db_email_addresses)
    end
  end
end
