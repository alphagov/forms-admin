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
end

def sync_live_forms
  live_forms = Form.where(state: "live").or(Form.where(state: "live_with_draft"))

  count = 0

  live_forms.each do |form|
    FormDocument.find_or_create_by!(form_id: form.id, tag: "live") do |form_doc|
      content = ApiFormDocumentService.form_document(form_id: form.id, tag: "live")
      form_doc.content = content
      count += 1
    end
  end

  puts "Created #{count} new live formdocs"
end

def sync_archived_forms
  archived_forms = Form.where(state: "archived").or(Form.where(state: "archived_with_draft"))

  count = 0
  archived_forms.each do |form|
    FormDocument.find_or_create_by!(form_id: form.id, tag: "archived") do |form_doc|
      content = ApiFormDocumentService.form_document(form_id: form.id, tag: "archived")
      form_doc.content = content
      count += 1
    end
  end

  puts "Created #{count} new archived formdocs"
end
