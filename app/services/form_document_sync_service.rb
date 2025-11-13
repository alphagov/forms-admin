class FormDocumentSyncService
  class << self
    def synchronize_form(form)
      case form.state
      when "live"
        sync_live_form(form)
      when "archived", "archived_with_draft"
        sync_archived_form(form)
      end
    end

    def update_draft_form_document(form)
      form.available_languages.each do |language|
        Mobility.with_locale(language) do
          content = form.as_form_document
          update_or_create_form_document(form, "draft", content, language:)
        end
      end
    end

  private

    def sync_live_form(form)
      FormDocument.transaction do
        form.available_languages.each do |language|
          Mobility.with_locale(language) do
            content = form.as_form_document(live_at: form.updated_at)
            update_or_create_form_document(form, "live", content, language:)
            delete_form_documents(form, "archived")
          end
        end
      end
    end

    def sync_archived_form(form)
      FormDocument.transaction do
        form.available_languages.each do |language|
          Mobility.with_locale(language) do
            live_form_document = FormDocument.find_by!(form:, tag: "live")
            update_or_create_form_document(form, "archived", live_form_document.content, language:)
            delete_form_documents(form, "live")
          end
        end
      end
    end

    def update_or_create_form_document(form, tag, content, language: "en")
      form_document = FormDocument.find_or_initialize_by(form_id: form.id, tag:, language:)
      form_document.content = content
      form_document.save!
    end

    def delete_form_documents(form, tag)
      FormDocument.where(form: form, tag:).delete_all
    end
  end
end
