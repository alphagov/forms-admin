require "rails_helper"

describe SubmissionEmailMailer, type: :mailer do
  let(:mail) do
    described_class.confirmation_code_email(
      new_submission_email: "test@example.com",
      form_name: "Testing API",
      confirmation_code: "654321",
      current_user: OpenStruct.new(name: "Joe Bloggs", email: "example@example.com", confirmation_code: "654321"),
    )
  end

  describe "sending an email to a given submission email to check its correct and receiving emails" do
    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.submission_email_confirmation_code_email_template_id)
    end

    it "sends an email to the temporary submission email address" do
      expect(mail.to).to eq(["test@example.com"])
    end

    it "includes the confirmation code" do
      expect(mail.govuk_notify_personalisation[:form_submission_email_code]).to eq("654321")
    end

    it "includes the form creators details" do
      expect(mail.govuk_notify_personalisation[:form_creator_name]).to eq("Joe Bloggs")
      expect(mail.govuk_notify_personalisation[:form_creator_email]).to eq("example@example.com")
    end

    it "includes the form name" do
      expect(mail.govuk_notify_personalisation[:form_name]).to eq("Testing API")
    end
  end
end
