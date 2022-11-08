require "rails_helper"

RSpec.describe Forms::ConfirmEmailForm, type: :model do
  context "when the form is live" do
    describe "Confirm Email" do
      let(:form) do
        build(:form, :live)
      end

      it "is invalid if blank" do
        confirm_email_form = described_class.new(form:, email_code: "")
        error_message = I18n.t("activemodel.errors.models.forms/confirm_email_form.attributes.email_code.blank")

        confirm_email_form.validate(:email_code)

        expect(confirm_email_form.errors.full_messages_for(:email_code)).to include(
          "Email code #{error_message}",
        )
      end

      it "is invalid if code is not in the correct format" do
        confirm_email_form = described_class.new(form:, email_code: "not numbers")
        error_message = I18n.t("activemodel.errors.models.forms/confirm_email_form.attributes.email_code.invalid_email_code")

        confirm_email_form.validate(:email_code)

        expect(confirm_email_form.errors.full_messages_for(:email_code)).to include(
          "Email code #{error_message}",
        )
      end

      it "is valid if code is in the correct format" do
        confirm_email_form = described_class.new(form:, email_code: "11111111")
        expect(confirm_email_form).to be_valid
      end
    end
  end
end
