class SubmissionEmailMailer < GovukNotifyRails::Mailer
  def send_confirmation_code(new_submission_email:, form_name:, confirmation_code:, notify_response_id:, current_user:)
    set_template(Settings.govuk_notify.submission_email_confirmation_code_email_template_id)

    set_personalisation(
      form_creator_name: current_user.name,
      form_creator_email: current_user.email,
      form_name:,
      form_submission_email_code: confirmation_code,
    )

    set_reference(notify_response_id)

    mail(to: new_submission_email)
  end

  def alert_email_change(live_email:, form_name:, current_user:)
    set_template(Settings.govuk_notify.live_submission_email_of_no_further_form_submissions)

    set_personalisation(
      form_creator_name: current_user.name,
      form_creator_email: current_user.email,
      form_name:,
    )

    mail(to: live_email)
  end
end
