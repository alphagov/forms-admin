namespace :users do
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
