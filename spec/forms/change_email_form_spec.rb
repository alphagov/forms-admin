require "rails_helper"

RSpec.describe Forms::ChangeEmailForm, type: :model do
  describe "Email" do
    it "is invalid if blank" do
      change_email_form = described_class.new(submission_email: "")
      error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.blank")

      change_email_form.validate(:submission_email)

      expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
        "Submission email #{error_message}",
      )
    end

    it "is invalid if email address is not in the correct format" do
      change_email_form = described_class.new(submission_email: "laura.mipsum")
      error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.invalid_email")

      change_email_form.validate(:submission_email)

      expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
        "Submission email #{error_message}",
      )
    end

    # More tests are required here -  e.g. that a valid submission updates the Form object
  end
end
