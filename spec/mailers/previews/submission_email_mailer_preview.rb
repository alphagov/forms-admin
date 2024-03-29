class SubmissionEmailMailerPreview < ActionMailer::Preview
  def confirmation_code_email
    SubmissionEmailMailer.confirmation_code_email(
      new_submission_email: "testing@example.com",
      form_name: "My fantastic form",
      confirmation_code: "12345",
      notify_response_id: "67890",
      current_user: OpenStruct.new(name: "Joe Bloggs", email: "example@example.com"),
    )
  end

  def notify_submission_email_has_changed
    SubmissionEmailMailer.notify_submission_email_has_changed(
      live_email: "testing@example.com",
      form_name: "My fantastic form",
      current_user: OpenStruct.new(name: "Joe Bloggs", email: "example@example.com"),
    )
  end
end
