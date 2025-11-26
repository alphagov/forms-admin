class FormDocumentSyncService
  attr_reader :form

  DRAFT_TAG = "draft".freeze
  LIVE_TAG = "live".freeze
  ARCHIVED_TAG = "archived".freeze

  def initialize(form)
    @form = form
  end

  def synchronize_live_form
    FormDocument.transaction do
      synchronize_documents_for_tag(LIVE_TAG, live_at: form.updated_at)

      # A new live version replaces any previous archived version
      delete_form_documents_by_tag(ARCHIVED_TAG)
    end
  end

  def synchronize_archived_form
    FormDocument.transaction do
      # Ensure we only archive forms that are currently live
      raise ActiveRecord::RecordNotFound, "Cannot archive a form that has no live version." unless live_documents.exists?

      # Remove any pre-existing archived documents
      delete_form_documents_by_tag(ARCHIVED_TAG)

      # Change all live documents to archived
      live_documents.update_all(tag: ARCHIVED_TAG)
    end
  end

  def update_draft_form_document
    synchronize_documents_for_tag(DRAFT_TAG)
  end

private

  # Create/update documents for all languages for a specific tag
  def synchronize_documents_for_tag(tag, **content_options)
    FormDocument.transaction do
      form.available_languages.each do |language|
        content = form_content(language, **content_options)
        update_or_create_form_document(tag, content, language)
      end

      # Clean up any documents for languages no longer used by the form
      delete_form_documents_for_unused_languages(tag)
    end
  end

  def update_or_create_form_document(tag, content, language)
    form_document = FormDocument.find_or_initialize_by(
      form_id: form.id,
      tag:,
      language:,
    )
    form_document.content = content
    form_document.save!
  end

  def delete_form_documents_by_tag(tag)
    form_documents_by_tag(tag).delete_all
  end

  def delete_form_documents_for_unused_languages(tag)
    form_documents_by_tag(tag)
      .where.not(language: form.available_languages)
      .delete_all
  end

  def form_documents_by_tag(tag)
    FormDocument.where(form:, tag:)
  end

  def live_documents
    form_documents_by_tag(LIVE_TAG)
  end

  def form_content(language, **options)
    Mobility.with_locale(language) do
      form.as_form_document(**options)
    end
  end
end
