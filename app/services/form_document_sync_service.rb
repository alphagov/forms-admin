class FormDocumentSyncService
  attr_reader :form

  def initialize(form)
    @form = form
  end

  def synchronize_form
    case form.state
    when "live"
      sync_live_form
    when "archived", "archived_with_draft"
      sync_archived_form
    end
  end

  def update_draft_form_document
    update_or_create_form_document("draft", form.as_form_document)
  end

private

  def sync_live_form
    content = form.as_form_document(live_at: form.updated_at)
    update_or_create_form_document("live", content)
    delete_form_documents("archived")
  end

  def sync_archived_form
    live_form_document = FormDocument.find_by!(form:, tag: "live")
    update_or_create_form_document("archived", live_form_document.content)
    delete_form_documents("live")
  end

  def update_or_create_form_document(tag, content)
    form_document = FormDocument.find_or_initialize_by(form_id: form.id, tag:)
    form_document.content = content
    form_document.save!
  end

  def delete_form_documents(tag)
    FormDocument.where(form:, tag:).delete_all
  end
end
