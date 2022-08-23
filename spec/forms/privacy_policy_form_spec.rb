require "rails_helper"

RSpec.describe Forms::PrivacyPolicyForm, type: :model do
  describe "Privacy policy URL" do
    it "is invalid if blank" do
      privacy_policy_form = described_class.new(privacy_policy_url: "")
      error_message = I18n.t("activemodel.errors.models.forms/privacy_policy_form.attributes.privacy_policy_url.blank")

      privacy_policy_form.validate(:privacy_policy_url)

      expect(privacy_policy_form.errors.full_messages_for(:privacy_policy_url)).to include(
        "Privacy policy url #{error_message}",
      )
    end

    it { is_expected.to validate_url_of(:privacy_policy_url) }

    # More tests are required here -  e.g. that a valid submission updates the Form object
  end
end
