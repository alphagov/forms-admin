namespace :groups do
  desc "change the organisation of one or more groups"
  task :change_organisation, [] => :environment do |_, args|
    run_task("groups:change_organisation", args, rollback: false)
  end

  desc "move one or more forms into group"
  task :change_organisation_dry_run, [] => :environment do |_, args|
    run_task("groups:change_organisation_dry_run", args, rollback: true)
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

def change_organisation(group_ids, org_id, task_name:)
  missing_groups = []

  begin
    organisation = Organisation.find(org_id)
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

  groups.each do |group|
    Rails.logger.info "#{task_name}: changing #{fmt_group(group)} from #{fmt_organisation(group.organisation)} to #{fmt_organisation(organisation)}"

    group.organisation = organisation
    group.save!
  end
end

def fmt_organisation(org)
  "organisation #{org.id} (#{org.name})"
end

def fmt_group(group)
  "group #{group.external_id} (#{group.name})"
end
