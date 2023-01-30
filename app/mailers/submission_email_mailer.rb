class SubmissionEmailMailer < GovukNotifyRails::Mailer
  def confirmation_code_email(new_submission_email:, form_name:, confirmation_code:, notify_response_id:, user_information:)
    set_template(Settings.govuk_notify.submission_email_confirmation_code_email_template_id)

    set_personalisation(
      form_creator_name: user_information.name,
      form_creator_email: user_information.email,
      form_name:,
      form_submission_email_code: confirmation_code,
    )

    set_reference(notify_response_id)

    mail(to: new_submission_email)
  end
end
