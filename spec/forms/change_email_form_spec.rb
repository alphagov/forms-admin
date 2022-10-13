require "rails_helper"

RSpec.describe Forms::ChangeEmailForm, type: :model do
  context "when the form is live" do
    describe "Email" do
      let(:form) do
        build(:form, :live)
      end

      it "is invalid if blank" do
        change_email_form = described_class.new(form:, submission_email: "")
        error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.blank")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
          "Submission email #{error_message}",
        )
      end

      it "is invalid if email address is not in the correct format" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum")
        error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.invalid_email")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
          "Submission email #{error_message}",
        )
      end

      it "is invalid if email address does not end in .gov.uk" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum@gmail.com")
        error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.non_govuk_email")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
          "Submission email #{error_message}",
        )
      end

      it "domain validation is case insensitive" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum@juggling.GOV.UK")

        change_email_form.validate(:submission_email)

        expect(change_email_form).to be_valid
      end

      # More tests are required here -  e.g. that a valid submission updates the Form object
    end
  end

  context "when the form is not live" do
    describe "Email" do
      let(:form) do
        build(:form)
      end

      it "is invalid if blank" do
        change_email_form = described_class.new(form:, submission_email: "")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to be_empty
      end

      it "is invalid if email address is not in the correct format" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum")
        error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.invalid_email")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
          "Submission email #{error_message}",
        )
      end

      it "is invalid if email address does not end in .gov.uk" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum@gmail.com")
        error_message = I18n.t("activemodel.errors.models.forms/change_email_form.attributes.submission_email.non_govuk_email")

        change_email_form.validate(:submission_email)

        expect(change_email_form.errors.full_messages_for(:submission_email)).to include(
          "Submission email #{error_message}",
        )
      end

      it "domain validation is case insensitive" do
        change_email_form = described_class.new(form:, submission_email: "laura.mipsum@juggling.GOV.UK")

        change_email_form.validate(:submission_email)

        expect(change_email_form).to be_valid
      end

      # More tests are required here -  e.g. that a valid submission updates the Form object
    end
  end
end
