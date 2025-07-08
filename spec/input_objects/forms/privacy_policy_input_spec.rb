require "rails_helper"

RSpec.describe Forms::PrivacyPolicyInput, type: :model do
  describe "Privacy policy URL" do
    context "when form is live" do
      let(:form) do
        build(:form, :live)
      end

      it "validates the URL" do
        privacy_policy_input = described_class.new(form:, privacy_policy_url: "gov.uk")
        error_message = I18n.t("errors.messages.url")

        privacy_policy_input.validate(:privacy_policy_url)

        expect(privacy_policy_input.errors.full_messages_for(:privacy_policy_url)).to include(
          "Privacy policy url #{error_message}",
        )
      end

      it "is invalid if the GOV.UK privacy notice is used" do
        privacy_policy_input = described_class.new(form:, privacy_policy_url: "https://www.gov.uk/help/privacy-notice")
        error_message = I18n.t("activemodel.errors.models.forms/privacy_policy_input.attributes.privacy_policy_url.exclusion")

        privacy_policy_input.validate(:privacy_policy_url)

        expect(privacy_policy_input.errors.full_messages_for(:privacy_policy_url)).to include(
          "Privacy policy url #{error_message}",
        )
      end

      it "is valid if blank" do
        privacy_policy_input = described_class.new(form:, privacy_policy_url: "")

        expect(privacy_policy_input).to be_valid
      end
    end

    context "when form is not live" do
      let(:form) do
        build(:form)
      end

      it "is valid if blank" do
        privacy_policy_input = described_class.new(form:, privacy_policy_url: "")

        privacy_policy_input.validate(:privacy_policy_url)

        expect(privacy_policy_input.errors.full_messages_for(:privacy_policy_url)).to be_empty
      end

      it "validates the URL" do
        privacy_policy_input = described_class.new(form:, privacy_policy_url: "gov.uk")
        error_message = I18n.t("errors.messages.url")

        privacy_policy_input.validate(:privacy_policy_url)

        expect(privacy_policy_input.errors.full_messages_for(:privacy_policy_url)).to include(
          "Privacy policy url #{error_message}",
        )
      end
    end
    # More tests are required here -  e.g. that a valid submission updates the Form object
  end
end
