require "digest"
require "MailchimpMarketing"

MailchimpMember = Data.define(:email, :status) do
  def unsubscribed?
    status == "unsubscribed"
  end

  def archivable?
    %w[subscribed cleaned pending transactional].include?(status)
  end

  def subscriber_hash
    Digest::MD5.hexdigest email.downcase
  end
end

class MailchimpListSynchronizer
  attr_reader :client, :list_id

  PAGE_SIZE = 1000

  def initialize(list_id:)
    @list_id = list_id
    @client = setup_client(Settings.mailchimp.api_key, Settings.mailchimp.api_prefix)
  end

  def setup_client(api_key, server)
    MailchimpMarketing::Client.new.tap do |client|
      client.set_config(
        api_key: api_key,
        server: server,
      )
    end
  end

  def synchronize(desired_members:)
    desired_members_hash = desired_members.index_by(&:subscriber_hash)
    existing_members_hash = fetch_all_members.index_by(&:subscriber_hash)

    add_and_update_members(existing_members_hash, desired_members_hash)
    archive_removed_members(existing_members_hash, desired_members_hash)
  end

  def add_and_update_members(existing_members, desired_members)
    Rails.logger.debug "Subscribing any new users..."
    members_to_update = []

    desired_members.each do |subscriber_hash, desired_member|
      existing_member = existing_members[subscriber_hash]

      next if existing_member&.unsubscribed?
      next if existing_member == desired_member

      members_to_update << desired_member
    end

    Rails.logger.debug "There are #{members_to_update} to subscribe"

    members_to_update.each do |member|
      update_member(member)
    end
  end

  def archive_removed_members(existing_members, desired_members)
    Rails.logger.debug "Archiving any removed users..."
    members_to_remove = []

    existing_members.each do |subscriber_hash, existing_member|
      if !desired_members[subscriber_hash] && existing_member.archivable?
        members_to_remove << existing_member
      end
    end

    Rails.logger.debug "There are #{members_to_remove.size} to archive"

    members_to_remove.each do |member|
      remove_member(member)
    end
  end

  def fetch_all_members
    return enum_for(:fetch_all_members) unless block_given?

    offset = 0
    mailchimp_list = client.lists.get_list(list_id, include_total_contacts: true)
    total_size = mailchimp_list["stats"]["total_contacts"]

    Rails.logger.debug "Found Mailchimp list: #{mailchimp_list['name']}"
    Rails.logger.debug "Mailchimp list has #{mailchimp_list['stats']['member_count']} active members"
    Rails.logger.debug "Mailchimp list has #{mailchimp_list['stats']['total_contacts']} total members"

    while offset < total_size
      response = client.lists.get_list_members_info(list_id, count: PAGE_SIZE, offset: offset)

      response["members"].each do |member_data|
        yield MailchimpMember.new(
          email: member_data["email_address"],
          status: member_data["status"],
        )
      end

      offset += PAGE_SIZE
    end
  end

  def update_member(member)
    member_data = {
      "email_address" => member.email,
      "status" => member.status,
    }

    client.lists.set_list_member(
      list_id,
      member.subscriber_hash,
      member_data,
    )
  rescue MailchimpMarketing::ApiError => e
    log_mailchimp_error("subscribe", member.subscriber_hash, e)
  end

  def remove_member(member)
    client.lists.delete_list_member(list_id, member.subscriber_hash)
  rescue MailchimpMarketing::ApiError => e
    log_mailchimp_error("archive", member.subscriber_hash, e)
  end

  def log_mailchimp_error(action, subscriber_hash, error)
    warn "Could not #{action} user with subscriber hash #{subscriber_hash} from list #{list_id}"
    warn "#{error.title}: #{error.detail}"
    warn "Continuing"
  end
end
