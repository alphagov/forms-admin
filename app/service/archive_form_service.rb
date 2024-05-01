class ArchiveFormService
  def initialize(form:, current_user:)
    @form = form
    @current_user = current_user
  end

  def archive
    @form.archive!
    SubmissionEmailMailer.alert_processor_form_archive(processor_email: @form.submission_email,
                                                       form_name: @form.name,
                                                       archived_by_name: @current_user.name,
                                                       archived_by_email: @current_user.email).deliver_now
  end
end
