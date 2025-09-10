namespace :form_documents do
  desc "retrieve all live and archived form documents from Forms API"
  task sync: :environment do
    puts "Started with #{FormDocument.count} formdocs"

    ActiveRecord::Base.transaction do
      sync_live_forms

      sync_archived_forms
    end

    puts "Finished with #{FormDocument.count} formdocs"
  end

  desc "dry run retrieve all live and archived form documents from Forms API"
  task sync_dry_run: :environment do
    puts "Started with #{FormDocument.count} formdocs"

    ActiveRecord::Base.transaction do
      sync_live_forms

      sync_archived_forms
      puts "Finished with #{FormDocument.count} formdocs"

      raise ActiveRecord::Rollback
    end
  end

  desc "create or update draft FormDocuments for all forms"
  task sync_draft_form_documents: :environment do
    Rails.logger.info "Started with #{FormDocument.where(tag: 'draft').count} draft FormDocuments"

    ActiveRecord::Base.transaction do
      Form.find_each do |form|
        FormDocumentSyncService.update_draft_form_document(form)
      end
    end

    Rails.logger.info "Finished with #{FormDocument.where(tag: 'draft').count} draft FormDocuments"
  end
end

def sync_live_forms
  live_forms = Form.where(state: "live").or(Form.where(state: "live_with_draft"))

  count = 0

  live_forms.each do |form|
    form_doc = FormDocument.find_or_initialize_by(form_id: form.id, tag: "live")
    form_doc.content = ApiFormDocumentService.form_document(form_id: form.id, tag: "live")
    form_doc.save!
    count += 1
  end

  puts "Created or updated #{count} live formdocs"
end

def sync_archived_forms
  archived_forms = Form.where(state: "archived").or(Form.where(state: "archived_with_draft"))

  count = 0

  archived_forms.each do |form|
    form_doc = FormDocument.find_or_initialize_by(form_id: form.id, tag: "archived")
    form_doc.content = ApiFormDocumentService.form_document(form_id: form.id, tag: "archived")
    form_doc.save!
    count += 1
  end

  puts "Created or updated #{count} archived formdocs"
end
