namespace :fix_first_made_live_at do
  desc "Updates forms to add first_made_live_at"
  task :update_date, [] => :environment do |_, args|
    Rails.logger.info "data_migration:update_date"

    update_forms_first_made_live_at(args.to_a)
  end

  desc "Dry run updates forms to add first_made_live_at"
  task :update_date_dry_run, [] => :environment do |_, args|
    ActiveRecord::Base.transaction do
      Rails.logger.info "data_migration:update_date_dry_run"

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
