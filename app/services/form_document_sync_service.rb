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
      live_form_document = FormDocument.find_or_initialize_by(form: form)
      live_form_document.tag = "live"
      live_form_document.content = form.as_form_document
      live_form_document.save!
    end

    def sync_archived_form(form)
      form_document = FormDocument.find_or_initialize_by(form:)
      unless form_document.persisted?
        form_document.content = ApiFormDocumentService.form_document(form_id: form.id, tag: "live")
      end
      form_document.tag = "archived"
      form_document.save!
    end
  end
end
