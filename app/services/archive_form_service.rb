class ArchiveFormService
  attr_reader :form, :current_user

  def initialize(form:, current_user:)
    @form = form
    @current_user = current_user
  end

  def archive
    form.archive_live_form!
    SubmissionEmailMailer.alert_processor_form_archive(processor_email: form.submission_email,
                                                       form_name: form.name,
                                                       archived_by_name: current_user.name,
                                                       archived_by_email: current_user.email).deliver_now
  end

  def archive_welsh_only
    return unless has_live_welsh_form?

    archive_welsh_form_document
  end

private

  def has_live_welsh_form?
    form.live_welsh_form_document.present?
  end

  def archive_welsh_form_document
    FormDocumentSyncService.new(form).synchronize_archived_welsh_form
  end
end
