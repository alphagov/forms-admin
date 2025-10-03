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

      form.save_draft!

      form.form_submission_email&.destroy!
    end
  end

  namespace :submission_type do
    desc "Set submission_type to email"
    task :set_to_email, %i[form_id] => :environment do |_, args|
      usage_message = "usage: rake forms:submission_type:set_to_email[<form_id>]".freeze
      abort usage_message if args[:form_id].blank?

      set_submission_type("email", args[:form_id])
    end

    desc "Set submission_type to email_with_csv"
    task :set_to_email_with_csv, %i[form_id] => :environment do |_, args|
      usage_message = "usage: rake forms:submission_type:set_to_email_with_csv[<form_id>]".freeze
      abort usage_message if args[:form_id].blank?

      set_submission_type("email_with_csv", args[:form_id])
    end

    desc "Set submission_type to s3"
    task :set_to_s3, %i[form_id s3_bucket_name s3_bucket_aws_account_id s3_bucket_region] => :environment do |_, args|
      usage_message = "usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>]".freeze
      abort usage_message if args[:form_id].blank?
      abort usage_message if args[:s3_bucket_name].blank?
      abort usage_message if args[:s3_bucket_aws_account_id].blank?
      abort usage_message if args[:s3_bucket_region].blank?
      abort "s3_bucket_region must be one of eu-west-1 or eu-west-2" unless %w[eu-west-1 eu-west-2].include? args[:s3_bucket_region]

      Rails.logger.info("Setting submission_type to s3 and s3_bucket_name to #{args[:s3_bucket_name]} for form: #{args[:form_id]}")
      form = Form.find(args[:form_id])
      form.submission_type = "s3"
      form.s3_bucket_name = args[:s3_bucket_name]
      form.s3_bucket_aws_account_id = args[:s3_bucket_aws_account_id]
      form.s3_bucket_region = args[:s3_bucket_region]
      form.save!

      if form.is_live?
        form_document = form.live_form_document
        content = form_document.content

        content[:submission_type] = "s3"
        content[:s3_bucket_name] = args[:s3_bucket_name]
        content[:s3_bucket_aws_account_id] = args[:s3_bucket_aws_account_id]
        content[:s3_bucket_region] = args[:s3_bucket_region]

        form_document.save!
      end

      Rails.logger.info("Set submission_type to s3 and s3_bucket_name to #{args[:s3_bucket_name]} for form: #{args[:form_id]}")
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

def set_submission_type(submission_type, form_id)
  Rails.logger.info("Setting submission_type to #{submission_type} for form: #{form_id}")

  form = Form.find(form_id)
  form.submission_type = submission_type
  form.save!

  if form.is_live?
    form_document = form.live_form_document
    content = form_document.content

    content[:submission_type] = submission_type

    form_document.save!
  end

  Rails.logger.info("Set submission_type to #{submission_type} for form: #{form_id}")
end
