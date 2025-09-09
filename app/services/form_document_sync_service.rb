class FormDocumentSyncService
  class << self
    def synchronize_form(form)
      case form.state
      when "live"
        sync_live_form(form)
      when "archived"
        sync_archived_form(form)
      end
    end

  private

    def sync_live_form(form)
      content = form.as_form_document(live_at: form.updated_at)
      update_or_create_form_document(form, "live", content)
      delete_form_documents(form, "archived")
    end

    def sync_archived_form(form)
      live_form_document = FormDocument.find_by!(form:, tag: "live")
      update_or_create_form_document(form, "archived", live_form_document.content)
      delete_form_documents(form, "live")
    end

    def update_or_create_form_document(form, tag, content)
      form_document = FormDocument.find_or_initialize_by(form_id: form.id, tag:)
      form_document.content = content
      form_document.save!
    end

    def delete_form_documents(form, tag)
      FormDocument.where(form: form, tag:).delete_all
    end
  end
end
