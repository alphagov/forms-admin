require "rails_helper"

RSpec.describe Pages::AddressSettingsInput, type: :model do
  let(:address_settings_input) { build :address_settings_input, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "address", form_id: 1 }

  it "has a valid factory" do
    expect(address_settings_input).to be_valid
  end

  describe "validations" do
    it "is invalid if no options are selected" do
      error_message = I18n.t("activemodel.errors.models.pages/address_settings_input.attributes.base.blank")
      address_settings_input.uk_address = "false"
      address_settings_input.international_address = "false"
      expect(address_settings_input).to be_invalid
      expect(address_settings_input.errors.full_messages_for(:base)).to include(error_message)
    end

    it "is invalid given a value which is neither true nor false" do
      uk_error_message = I18n.t("activemodel.errors.models.pages/address_settings_input.attributes.uk_address.inclusion")
      international_error_message = I18n.t("activemodel.errors.models.pages/address_settings_input.attributes.international_address.inclusion")
      address_settings_input.uk_address = "maybe"
      address_settings_input.international_address = "possibly"
      expect(address_settings_input).to be_invalid
      expect(address_settings_input.errors.full_messages_for(:uk_address)).to include("Uk address #{uk_error_message}")
      expect(address_settings_input.errors.full_messages_for(:international_address)).to include("International address #{international_error_message}")
    end

    it "is valid if address settings are valid" do
      valid_combinations = [
        { uk_address: "true", international_address: "true" },
        { uk_address: "true", international_address: "false" },
        { uk_address: "false", international_address: "true" },
      ]
      valid_combinations.each do |combination|
        address_settings_input.uk_address = combination[:uk_address]
        address_settings_input.international_address = combination[:international_address]
        expect(address_settings_input).to be_valid
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(address_settings_input).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(address_settings_input).to receive(:invalid?).and_return(true)
      expect(address_settings_input.submit).to be_falsey
    end

    it "sets draft_question answer_settings" do
      address_settings_input.uk_address = "false"
      address_settings_input.international_address = "true"
      address_settings_input.submit

      expected_settings = {
        input_type: {
          uk_address: "false",
          international_address: "true",
        },
      }

      expect(address_settings_input.draft_question.answer_settings).to include(expected_settings)
    end
  end
end
