require "digest"
require "MailchimpMarketing"

namespace :mailchimp do
  desc "Synchronise Mailchimp audiences with the users in the database"
  task synchronize_audiences: :environment do
    mailchimp_api_key = ENV["MAILCHIMP_API_KEY"]
    mailchimp_server_prefix = ENV["MAILCHIMP_SERVER_PREFIX"]
    mailchimp_lists = ENV["MAILCHIMP_LISTS"]

    puts "Mailchimp server prefix: #{mailchimp_server_prefix}"
    puts "Mailchimp lists: #{mailchimp_lists}"

    mailchimp = MailchimpMarketing::Client.new
    mailchimp.set_config({
      api_key: mailchimp_api_key,
      server: mailchimp_server_prefix,
    })

    list_ids = mailchimp_lists
                  .split(",")
                  .map(&:strip)

    db_email_addresses = User.pluck(:email).to_set

    puts "There are #{list_ids.length} lists to synchronize"
    list_ids.each do |list_id|
      puts "List id: #{list_id}"

      target_list = mailchimp.lists.get_list(list_id)
      target_list or raise

      puts "Found Mailchimp list: #{target_list['name']}"
      puts "Mailchimp list has #{target_list['stats']['member_count']} members"

      existing_members = mailchimp.lists.get_list_members_info(list_id)
      list_email_addresses = existing_members["members"]
                               .map { |member| member["email_address"] }
                               .to_set

      deleted_users = list_email_addresses - db_email_addresses
      added_users = db_email_addresses - list_email_addresses

      puts "There are #{added_users.size} to subscribe"
      puts "There are #{deleted_users.size} to unsubscribe"

      puts "Subscribing any new users..."
      added_users.each do |email|
        subscriber_hash = Digest::MD5.hexdigest email.downcase
        mailchimp.lists.set_list_member(
          list_id,
          subscriber_hash,
          {
            "email_address" => email,
            "status_if_new" => "subscribed",
          },
        )
      rescue MailchimpMarketing::ApiError
        warn "Could not subscribe user with subscriber hash #{subscriber_hash} to list #{list_id}. Continuing"
      end

      puts "Unsubscribing any removed users..."
      deleted_users.each do |email|
        subscriber_hash = Digest::MD5.hexdigest email.downcase
        mailchimp.lists.delete_list_member_permanent(list_id, subscriber_hash)
      rescue MailchimpMarketing::ApiError
        warn "Could not unsubscribe user with subscriber hash #{subscriber_hash} from list #{list_id}. Continuing"
      end
    end
  end
end
