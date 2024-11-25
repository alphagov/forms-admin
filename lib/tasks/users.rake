namespace :users do
  require "auth0"

  desc "Update all trial and editor users to be standard users - dry run"
  task update_user_roles_to_standard_dry_run: :environment do
    ActiveRecord::Base.transaction do
      update_user_roles
      Rails.logger.info "users:update_user_roles_to_standard_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end

  desc "Update all trial and editor users to be standard users"
  task update_user_roles_to_standard: :environment do
    update_user_roles
  end

  desc "Delete user accounts with no name or organisation"
  task delete_users_with_no_name_or_org: :environment do
    auth0_client = Auth0Client.new(
      client_id: Settings.auth0.client_id,
      client_secret: Settings.auth0.client_secret,
      domain: Settings.auth0.domain,
    )

    deleted_count = 0
    skipped_count = 0

    User.where(name: nil).or(User.where(organisation: nil)).find_each do |user|
      Rails.logger.info("Deleting user #{user.email} with uid #{user.uid}")

      if user.memberships.present?
        group_ids = user.memberships.map { |membership| membership.group.external_id }
        Rails.logger.info("Skipping deleting user #{user.email} as they are a member of a group. Group IDs: #{group_ids}")
        skipped_count += 1
        next
      end

      Form.where(creator_id: user.id).find_all do |form|
        Rails.logger.info("Deleting form with id #{form.id} for user #{user.email}")
        # rubocop:disable Rails/SaveBang
        form.destroy
        # rubocop:enable Rails/SaveBang
      end

      if user.provider == "auth0" && user.uid.present?
        auth0_client.delete_user(user.uid)
        Rails.logger.info("Deleted auth0 account for user #{user.email} with auth0 uid #{user.uid}")
      else
        Rails.logger.info("User #{user.email} does not have an auth0 account")
      end

      user.delete
      deleted_count += 1
      Rails.logger.info("Deleted user #{user.email} with uid #{user.uid}")
    end

    Rails.logger.info("Finished deleting users, deleted #{deleted_count} users, skipped #{skipped_count} users that are in groups")
  end
end

def update_user_roles
  Rails.logger.info("Number of trial users: #{User.where(role: 'trial').count}")
  Rails.logger.info("Number of editor users: #{User.where(role: 'editor').count}")
  Rails.logger.info("Number of standard users: #{User.where(role: 'standard').count}")
  Rails.logger.info("Number of organisation_admin users: #{User.where(role: 'organisation_admin').count}")
  Rails.logger.info("Number of super_admin users: #{User.where(role: 'super_admin').count}")

  User.where(role: %w[trial editor]).update_all(role: "standard")

  Rails.logger.info("Number of trial users: #{User.where(role: 'trial').count}")
  Rails.logger.info("Number of editor users: #{User.where(role: 'editor').count}")
  Rails.logger.info("Number of standard users: #{User.where(role: 'standard').count}")
  Rails.logger.info("Number of organisation_admin users: #{User.where(role: 'organisation_admin').count}")
  Rails.logger.info("Number of super_admin users: #{User.where(role: 'super_admin').count}")
end
