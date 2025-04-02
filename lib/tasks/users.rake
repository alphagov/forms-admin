namespace :users do
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

  desc "Delete users with no name or organisation set"
  task delete_users_with_no_name_or_org: :environment do
    delete_users_with_no_name_or_org
  end

  namespace :delete_users_with_no_name_or_org do
    desc "Delete users with no name or organisation set - dry run"
    task dry_run: :environment do
      delete_users_with_no_name_or_org(dry_run: true)
    end
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

def delete_users_with_no_name_or_org(dry_run: false)
  task_name = "users:#{__method__}"
  task_name = "#{task_name}:dry_run" if dry_run

  users = User.where(name: nil).or(User.where(organisation: nil))
  users_count = users.count
  deleted_count = 0

  Rails.logger.info "#{task_name}: Found #{users.count} users without a name or organisation set"

  users.find_each do |user|
    Rails.logger.info "#{task_name}: Found user #{user.id} (#{user.email}) without a name or organisation set"

    if user.last_signed_in_at && (Time.zone.now - user.last_signed_in_at) < 20.hours
      Rails.logger.info "#{task_name}: User could still have active session, skipping deleting user #{user.id} (#{user.email})"
      next
    end

    if user.memberships.present?
      Rails.logger.info "#{task_name}: Found user in groups #{user.memberships.pluck(:group_id)}, skipping deleting user #{user.id} (#{user.email})"
      next
    end

    forms = Api::V1::FormResource.where(creator_id: user.id).find_all

    if forms.any?(&:is_live?)
      Rails.logger.info "#{task_name}: Found live forms #{forms.select(&:is_live?).map(&:id)} created by user, skipping deleting user #{user.id} (#{user.email})"
      next
    end

    forms_in_groups = GroupForm.where(form_id: forms.map(&:id)).pluck(:form_id)
    if forms_in_groups.any?
      Rails.logger.info "#{task_name}: Found forms #{forms_in_groups} created by user in groups, skipping deleting user #{user.id} (#{user.email})"
      next
    end

    # we need to delete all draft questions for this user or else PostgreSQL will complain
    DraftQuestion.destroy_by(user:)

    forms.each do |form|
      if dry_run || form.destroy
        Rails.logger.info "#{task_name}: Deleted form #{form.id} (\"#{form.name}\") created by user #{user.id} (#{user.email})"
      else
        Rails.logger.info "#{task_name}: Unable to delete form #{form.id} (\"#{form.name}\") created by user, skipping deleting user #{user.id} (#{user.email})"
        next
      end
    end

    if dry_run || user.destroy
      Rails.logger.info "#{task_name}: Deleted user #{user.id} (#{user.email})"
      deleted_count += 1
    else
      Rails.logger.info "#{task_name}: Unable to delete user #{user.id} (#{user.email})"
    end
  end

  Rails.logger.info "#{task_name}: Deleted #{deleted_count} users, skipped deleting #{users_count - deleted_count} users"
  Rails.logger.info "#{task_name}: Finished dry run, no changes persisted" if dry_run
end
