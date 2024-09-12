namespace :forms do
  desc "move one or more forms into group"
  task :move, [] => :environment do |_, args|
    *form_ids, group_id = args.to_a

    usage_message = "usage: rake forms:move[<form_id>, ..., <group_id>]".freeze
    abort usage_message if form_ids.blank? || group_id.blank?

    ActiveRecord::Base.transaction do
      move_forms(form_ids, group_id)
    end
  end

  desc "move one or more forms into group"
  task :move_dry_run, [] => :environment do |_, args|
    *form_ids, group_id = args.to_a

    usage_message = "usage: rake forms:move_dry_run[<form_id>, ..., <group_id>]".freeze
    abort usage_message if form_ids.blank? || group_id.blank?

    ActiveRecord::Base.transaction do
      move_forms(form_ids, group_id)
      Rails.logger.info "forms:move_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end

  namespace :submission_email do
    desc "set the submission email for a form, without validation"
    task :update, %i[form_id submission_email] => :environment do |_, args|
      usage_message = "usage: rake forms:submission_email:update[<form_id>, <submission_email>]".freeze
      abort usage_message if args[:form_id].blank? || args[:submission_email].blank?
      raise "'#{args[:submission_email]}' is not an email address" unless args[:submission_email].match?(/.*@.*/)

      form = Form.find(args[:form_id])
      form.submission_email = args[:submission_email]

      Rails.logger.info "forms:submission_email:update: setting #{fmt_form(form)} submission email to \'#{form.submission_email}\'"

      form.save!

      form.form_submission_email&.destroy!
    end
  end
end

def move_forms(form_ids, group_id)
  group = Group.find_by! external_id: group_id

  form_ids.each do |form_id|
    form = Form.find(form_id)
    group_form = GroupForm.find_or_initialize_by(form_id:)

    if group_form.group == group
      Rails.logger.info "forms:move: keeping #{fmt_form(form)} in #{fmt_group(group)}"
      next
    elsif group_form.persisted?
      Rails.logger.info "forms:move: moving #{fmt_form(form)} from #{fmt_group(group_form.group)} to #{fmt_group(group)}"
    else
      Rails.logger.info "forms:move: adding #{fmt_form(form)} to #{fmt_group(group)}"
    end

    group_form.update!(group:)
  end
end

def fmt_form(form)
  "form #{form.id} (\"#{form.name}\")"
end

def fmt_group(group)
  "group #{group.external_id} (\"#{group.name}\", #{group.organisation.name}, #{group.creator&.name || 'GOV.UK Forms Team'})"
end
