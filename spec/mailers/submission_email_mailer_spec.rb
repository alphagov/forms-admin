require "rails_helper"

describe SubmissionEmailMailer, type: :mailer do
  describe "#send_confirmation_code" do
    let(:mail) do
      described_class.send_confirmation_code(
        new_submission_email: "test@example.com",
        form_name: "Testing API",
        confirmation_code: "654321",
        notify_response_id: "abc-123",
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

      it "includes a UUID reference when the form was submit and can be used to find email in notify" do
        expect(mail.govuk_notify_reference).to eq("abc-123")
      end
    end
  end

  describe "#notify_submission_email_has_changed" do
    let(:mail) do
      described_class.alert_email_change(live_email: "test@example.com",
                                         form_name: "Testing API",
                                         current_user: OpenStruct.new(name: "Joe Bloggs", email: "example@example.com"))
    end

    describe "sending an email to notify confirmed submission email not to expect future form submissions" do
      it "sends an email with the correct template" do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.live_submission_email_of_no_further_form_submissions)
      end

      it "sends an email to the live submission email address" do
        expect(mail.to).to eq(["test@example.com"])
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
end
