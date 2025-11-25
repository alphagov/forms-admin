class FormDocumentSyncService
  attr_reader :form

  DRAFT_TAG = "draft".freeze
  LIVE_TAG = "live".freeze
  ARCHIVED_TAG = "archived".freeze

  def initialize(form)
    @form = form
  end

  def synchronize_live_form
    content = form.as_form_document(live_at: form.updated_at)
    update_or_create_form_document(LIVE_TAG, content)
    delete_form_documents(ARCHIVED_TAG)
  end

  def synchronize_archived_form
    live_form_document = FormDocument.find_by!(form:, tag: LIVE_TAG)
    update_or_create_form_document(ARCHIVED_TAG, live_form_document.content)
    delete_form_documents(LIVE_TAG)
  end

  def update_draft_form_document
    update_or_create_form_document(DRAFT_TAG, form.as_form_document)
  end

private

  def update_or_create_form_document(tag, content)
    form_document = FormDocument.find_or_initialize_by(form_id: form.id, tag:)
    form_document.content = content
    form_document.save!
  end

  def delete_form_documents(tag)
    FormDocument.where(form:, tag:).delete_all
  end
end
