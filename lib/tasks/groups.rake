namespace :groups do
  desc "change the organisation of one or more groups"
  task :change_organisation, [] => :environment do |_, args|
    run_task("groups:change_organisation", args, rollback: false)
  end

  desc "change the organisation of one or more groups (dry run)"
  task :change_organisation_dry_run, [] => :environment do |_, args|
    run_task("groups:change_organisation_dry_run", args, rollback: true)
  end

  desc "Create default trial group for user who has forms not in a group"
  task :create_user_default_trial_group, %i[user_id] => :environment do |_, args|
    usage_message = "usage: rake create_user_default_trial_group[<user_id>]".freeze
    abort usage_message if args[:user_id].blank?

    user = User.find(args[:user_id])
    DefaultGroupService.new.create_user_default_trial_group!(user)
  end

  desc "Move all groups in one organisation to another"
  task :move_all_groups_between_organisations, %i[source_organisation_id target_organisation_id] => :environment do |_, args|
    task_name = "groups:move_all_groups_between_organisations"
    source_organisation_id = args[:source_organisation_id]
    target_organisation_id = args[:target_organisation_id]

    run_bulk_task(task_name:, source_organisation_id:, target_organisation_id:, rollback: false)
  end

  desc "Move all groups in one organisation to another (dry run)"
  task :move_all_groups_between_organisations_dry_run, %i[source_organisation_id target_organisation_id] => :environment do |_, args|
    task_name = "groups:move_all_groups_between_organisations_dry_run"
    source_organisation_id = args[:source_organisation_id]
    target_organisation_id = args[:target_organisation_id]

    run_bulk_task(task_name:, source_organisation_id:, target_organisation_id:, rollback: true)
  end

  desc "Remove empty group"
  task :remove_group, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:remove_group[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?
    remove_group("groups:remove_group", args[:group_id])
  end

  desc "Remove empty group dry run"
  task :remove_group_dry_run, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:remove_group_run[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?

    ActiveRecord::Base.transaction do
      remove_group("groups:remove_group_dry_run", args[:group_id])
      raise ActiveRecord::Rollback
    end
  end

  desc "Enable long lists feature"
  task :enable_long_lists, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:enable_long_lists[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?

    Group.find_by(external_id: args[:group_id]).update!(long_lists_enabled: true)
    Rails.logger.info("Updated long_lists_enabled to true for group #{args[:group_id]}")
  end

  desc "Disable long lists feature"
  task :disable_long_lists, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:disable_long_lists[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?

    Group.find_by(external_id: args[:group_id]).update!(long_lists_enabled: false)
    Rails.logger.info("Updated long_lists_enabled to false for group #{args[:group_id]}")
  end

  desc "Enable file upload feature"
  task :enable_file_upload, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:enable_file_upload[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?

    Group.find_by(external_id: args[:group_id]).update!(file_upload_enabled: true)
    Rails.logger.info("Updated file_upload_enabled to true for group #{args[:group_id]}")
  end

  desc "Disable file upload feature"
  task :disable_file_upload, %i[group_id] => :environment do |_, args|
    usage_message = "usage: rake groups:disable_file_upload[<group_external_id>]".freeze
    abort usage_message if args[:group_id].blank?

    Group.find_by(external_id: args[:group_id]).update!(file_upload_enabled: false)
    Rails.logger.info("Updated file_upload_enabled to false for group #{args[:group_id]}")
  end
end

def run_task(task_name, args, rollback:)
  *group_ids, org_id = args.to_a

  usage_message = "usage: rake #{task_name}[<group_external_id>, ..., <organisation_id>]".freeze
  abort usage_message if group_ids.blank? || org_id.blank?

  ActiveRecord::Base.transaction do
    change_organisation(group_ids, org_id, task_name:)
    raise ActiveRecord::Rollback if rollback
  end
end

def run_bulk_task(task_name:, source_organisation_id:, target_organisation_id:, rollback:)
  usage_message = "usage: rake #{task_name}[<source_organisation_id>, <target_organisation_id>]".freeze
  abort usage_message if source_organisation_id.blank? || target_organisation_id.blank?

  ActiveRecord::Base.transaction do
    source_organisation = Organisation.find_by(id: source_organisation_id)
    target_organisation = Organisation.find_by(id: target_organisation_id)

    raise ActiveRecord::RecordNotFound, "No organisation associated with source_organisation #{source_organisation_id}" if source_organisation.blank?
    raise ActiveRecord::RecordNotFound, "No organisation associated with target_organisation_id #{target_organisation_id}" if target_organisation.blank?

    groups = source_organisation.groups

    update_groups(groups:, target_organisation:, task_name:)
    raise ActiveRecord::Rollback if rollback
  end
end

def change_organisation(group_ids, org_id, task_name:)
  missing_groups = []

  begin
    target_organisation = Organisation.find(org_id)
  rescue ActiveRecord::RecordNotFound
    abort "Organisation with ID #{org_id} not found!"
  end

  groups = group_ids.map do |group_id|
    Group.find_by!(external_id: group_id)
  rescue ActiveRecord::RecordNotFound
    missing_groups << group_id
    nil
  end

  groups = groups.compact

  unless missing_groups.empty?
    abort "Groups with external ids #{missing_groups.join(', ')} not found!"
  end

  update_groups(groups:, target_organisation:, task_name:)
end

def update_groups(groups:, target_organisation:, task_name:)
  groups.each do |group|
    Rails.logger.info "#{task_name}: changing #{fmt_group(group)} from #{fmt_organisation(group.organisation)} to #{fmt_organisation(target_organisation)}"

    group.organisation = target_organisation
    group.save!
  end
end

def fmt_organisation(org)
  "organisation #{org.id} (#{org.name})"
end

def fmt_group(group)
  "group #{group.external_id} (#{group.name})"
end

def fmt_form(form)
  "form #{form.id} (#{form.name})"
end

def remove_group(task_name, group_id)
  group = Group.find_by!(external_id: group_id)

  Rails.logger.info "#{task_name}: trying to remove #{fmt_group(group)}"

  if group.group_forms.any?
    Rails.logger.info "#{task_name}: #{fmt_group(group)} contains #{group.group_forms.count} forms. Please remove the forms first."
    raise SystemExit
  end

  group.destroy!
  Rails.logger.info "#{task_name}: removed #{fmt_group(group)}"
end
