class ArchiveFormService
  def archive_form(form, user)
    form.archive!

    SubmissionEmailMailer.alert_processor_form_archive(processor_email: form.submission_email,
                                                       form_name: form.name,
                                                       creator_name: user.name,
                                                       creator_email: user.email)
  end
end
