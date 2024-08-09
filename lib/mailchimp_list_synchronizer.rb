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

    target_list = mailchimp.lists.get_list(list_id, include_total_contacts: true)
    target_list or raise

    puts "Found Mailchimp list: #{target_list['name']}"
    puts "Mailchimp list has #{target_list['stats']['member_count']} active members"
    puts "Mailchimp list has #{target_list['stats']['total_contacts']} total members"

    currently_subscribed_members = []
    unsubscribed_members = []

    # Set up API pagination
    total_list_size = target_list["stats"]["total_contacts"]
    offset = 0
    page_size = 1000 # maximum page size is 1000 results, default is 10

    while offset < total_list_size
      api_response = mailchimp.lists.get_list_members_info(list_id, count: page_size, offset:)

      api_response["members"].each do |member|
        currently_subscribed_members.push(member["email_address"]) if member["status"] == "subscribed"
        unsubscribed_members.push(member["email_address"]) if member["status"] == "unsubscribed"
      end

      offset += page_size
    end

    users_to_synchronize_set = users_to_synchronize
                             .to_set

    currently_subscribed_members_set = currently_subscribed_members
                             .to_set

    unsubscribed_members_set = unsubscribed_members.to_set

    users_to_archive = currently_subscribed_members_set - users_to_synchronize_set
    users_to_subscribe = (users_to_synchronize_set - currently_subscribed_members_set) - unsubscribed_members_set

    puts "There are #{users_to_subscribe.size} to subscribe"
    puts "There are #{users_to_archive.size} to archive"

    puts "Subscribing any new users..."
    users_to_subscribe.each do |email|
      subscriber_hash = Digest::MD5.hexdigest email.downcase
      mailchimp.lists.set_list_member(
        list_id,
        subscriber_hash,
        {
          "email_address" => email,
          "status" => "subscribed",
        },
      )
    rescue MailchimpMarketing::ApiError => e
      warn "Could not subscribe user with subscriber hash #{subscriber_hash} to list #{list_id}."
      warn "#{e.title}: #{e.detail}"
      warn "Continuing"
    end

    puts "Archiving any removed users..."
    users_to_archive.each do |email|
      subscriber_hash = Digest::MD5.hexdigest email.downcase
      mailchimp.lists.delete_list_member(list_id, subscriber_hash)
    rescue MailchimpMarketing::ApiError => e
      warn "Could not archive user with subscriber hash #{subscriber_hash} from list #{list_id}"
      warn "#{e.title}: #{e.detail}"
      warn "Continuing"
    end
  end
end
