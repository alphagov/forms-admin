class SubmissionEmailMailerPreview < ActionMailer::Preview
  def confirmation_code_email
    SubmissionEmailMailer.confirmation_code_email(new_submission_email: "testing@example.com")
  end
end
