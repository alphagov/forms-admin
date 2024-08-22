namespace :groups do
  desc "change the organisation of one or more groups"
  task :change_organisation, [] => :environment do |_, args|
    run_task("groups:change_organisation", args, rollback: false)
  end

  desc "move one or more forms into group"
  task :change_organisation_dry_run, [] => :environment do |_, args|
    run_task("groups:change_organisation_dry_run", args, rollback: true)
  end

  desc "Move all groups in one organisation to another"
  task :move_all_groups_between_organisations, %i[source_organisation_id target_organisation_id] => :environment do |_, args|
    task_name = "groups:move_all_groups_between_organisations"
    source_organisation_id = args[:source_organisation_id]
    target_organisation_id = args[:target_organisation_id]

    run_bulk_task(task_name:, source_organisation_id:, target_organisation_id:, rollback: false)
  end
end

def run_task(task_name, args, rollback:)
  *group_ids, org_id = args.to_a

  usage_message = "usage: rake #{task_name}[<group_external_id>, ..., <organisation_id>]".freeze
  abort usage_message if group_ids.blank? || org_id.blank?

  ActiveRecord::Base.transaction do
    change_organisation(group_ids, org_id, task_name:, rollback:)
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

    update_groups(groups:, target_organisation:, task_name:, rollback:)
    raise ActiveRecord::Rollback if rollback
  end
end

def change_organisation(group_ids, org_id, task_name:, rollback:)
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

  update_groups(groups:, target_organisation:, task_name:, rollback:)
end

def update_groups(groups:, target_organisation:, task_name:, rollback:)
  groups.each do |group|
    Rails.logger.info "#{task_name}: changing #{fmt_group(group)} from #{fmt_organisation(group.organisation)} to #{fmt_organisation(target_organisation)}"

    group.organisation = target_organisation
    group.save!

    # change organisation for each form in the group
    group.group_forms.map(&:form).each do |form|
      Rails.logger.info "#{task_name}: changing #{fmt_form(form)} from #{fmt_organisation(form.organisation)} to #{fmt_organisation(target_organisation)}"

      form.organisation_id = group.organisation_id
      form.save! unless rollback
    end
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
