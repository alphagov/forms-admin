require "digest"
require "MailchimpMarketing"

class MailchimpListSynchronizer
  def self.synchronize(list_id:, users_to_synchronize:)
    mailchimp_api_key = Settings.mailchimp.api_key
    mailchimp_server_prefix = Settings.mailchimp.api_prefix
    puts "Mailchimp server prefix: #{mailchimp_server_prefix}"
    mailchimp = MailchimpMarketing::Client.new
    mailchimp.set_config({
      api_key: mailchimp_api_key,
      server: mailchimp_server_prefix,
    })
    puts "List id: #{list_id}"

    target_list = mailchimp.lists.get_list(list_id)
    target_list or raise

    puts "Found Mailchimp list: #{target_list['name']}"
    puts "Mailchimp list has #{target_list['stats']['member_count']} members"

    existing_members = []

    # Set up API pagination
    total_list_size = target_list["stats"]["member_count"]
    offset = 0
    page_size = 1000 # maximum page size is 1000 results, default is 10

    while offset < total_list_size
      api_response = mailchimp.lists.get_list_members_info(list_id, count: page_size, offset:)
      api_email_addresses = api_response["members"].map { |member| member["email_address"] }
      existing_members.concat(api_email_addresses)

      offset += page_size
    end

    users_to_synchronize_set = users_to_synchronize
                             .to_set

    existing_members_set = existing_members
                             .to_set

    deleted_users = existing_members_set - users_to_synchronize_set
    added_users = users_to_synchronize_set - existing_members_set

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
