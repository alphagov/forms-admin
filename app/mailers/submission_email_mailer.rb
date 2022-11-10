class SubmissionEmailMailer < GovukNotifyRails::Mailer
  def confirmation_code_email(new_submission_email:, form_name:, confirmation_code:, current_user:)
    set_template(Settings.govuk_notify.submission_email_confirmation_code_email_template_id)

    set_personalisation(
      form_creator_name: current_user.name,
      form_creator_email: current_user.email,
      form_name:,
      form_submission_email_code: confirmation_code,
    )

    mail(to: new_submission_email)
  end
end
