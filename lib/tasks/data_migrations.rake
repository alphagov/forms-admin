namespace :data_migrations do
  desc "Updates form documents to remove the database_id attribute from steps"
  task remove_step_database_ids: :environment do
    form_documents = FormDocument.where("(content -> 'steps' -> 0) ? :key", key: "database_id")
    Rails.logger.info "data_migrations:remove_step_database_ids will update #{form_documents.count} form_documents"

    form_documents.find_each do |form_document|
      form_document.content["steps"].each { |s| s.delete("database_id") }
      form_document.save!
    end

    Rails.logger.info "data_migrations:remove_step_database_ids finished"
  end

  desc "Updates forms to add first_made_live_at"
  task :add_first_made_live_at_to_forms, [] => :environment do |_, args|
    Rails.logger.info "data_migration:add_first_made_live_at_to_forms"

    update_forms_first_made_live_at(args.to_a)
  end

  desc "Dry run updates forms to add first_made_live_at"
  task :dry_run_add_first_made_live_at_to_forms, [] => :environment do |_, args|
    ActiveRecord::Base.transaction do
      Rails.logger.info "data_migration:dry_run_add_first_made_live_at_to_forms"

      update_forms_first_made_live_at(args.to_a)

      raise ActiveRecord::Rollback
    end
  end
end

def update_forms_first_made_live_at(forms_and_dates)
  Rails.logger.info "Updating #{forms_and_dates.length} forms"

  forms_and_dates.each do |form_and_date|
    form_id, first_made_live_at = form_and_date.split(":", 2)
    first_made_live_at = Time.zone.parse(first_made_live_at)

    Rails.logger.info "Updating form #{form_id} to have first_made_live_at #{first_made_live_at}"

    form = Form.find(form_id)
    form.first_made_live_at = first_made_live_at

    begin
      form.save!

      form.form_documents.each do |form_document|
        form_document.content[:first_made_live_at] = first_made_live_at

        form_document.save!
      end
    rescue StandardError => e
      Rails.logger.info "Failed to update form #{form_id}: #{e.message}"
    end
  end
end
