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

  desc "Delete user (dry run)"
  task :delete_user_dry_run, %i[user_id] => :environment do |_, args|
    run_deletion_task("delete_user_dry_run", args, rollback: true)
  end

  desc "Delete user"
  task :delete_user, %i[user_id] => :environment do |_, args|
    # This task doesn't check whether the user is associated with any forms or groups.
    # Before running the task, remove the user from any groups and reassign their forms to another user.
    run_deletion_task("delete_user", args, rollback: false)
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

def run_deletion_task(task_name, args, rollback:)
  usage_message = "usage: rake #{task_name}[<user_id>]".freeze
  abort usage_message if args[:user_id].blank?

  ActiveRecord::Base.transaction do
    user = User.find(args[:user_id])
    user.destroy!
    Rails.logger.info("Deleted user: #{args[:user_id]}")
    Rails.logger.info("users:delete_user_dry_run: rollback deletion of user #{args[:user_id]}") if rollback
    raise ActiveRecord::Rollback if rollback
  end
end
