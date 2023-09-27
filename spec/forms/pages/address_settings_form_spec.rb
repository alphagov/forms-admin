require "rails_helper"

RSpec.describe Pages::AddressSettingsForm, type: :model do
  let(:address_settings_form) { described_class.new(draft_question:) }
  let(:draft_question) { build :draft_question, form_id: 1, user: }
  let(:user) { build :user }

  it "has a valid factory" do
    address_settings_form = build :address_settings_form
    expect(address_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if no options are selected" do
      error_message = I18n.t("activemodel.errors.models.pages/address_settings_form.attributes.base.blank")
      address_settings_form.uk_address = "false"
      address_settings_form.international_address = "false"
      expect(address_settings_form).to be_invalid
      expect(address_settings_form.errors.full_messages_for(:base)).to include(error_message)
    end

    it "is invalid given a value which is neither true nor false" do
      uk_error_message = I18n.t("activemodel.errors.models.pages/address_settings_form.attributes.uk_address.inclusion")
      international_error_message = I18n.t("activemodel.errors.models.pages/address_settings_form.attributes.international_address.inclusion")
      address_settings_form.uk_address = "maybe"
      address_settings_form.international_address = "possibly"
      expect(address_settings_form).to be_invalid
      expect(address_settings_form.errors.full_messages_for(:uk_address)).to include("Uk address #{uk_error_message}")
      expect(address_settings_form.errors.full_messages_for(:international_address)).to include("International address #{international_error_message}")
    end

    it "is valid if address settings are valid" do
      valid_combinations = [
        { uk_address: "true", international_address: "true" },
        { uk_address: "true", international_address: "false" },
        { uk_address: "false", international_address: "true" },
      ]
      valid_combinations.each do |combination|
        address_settings_form.uk_address = combination[:uk_address]
        address_settings_form.international_address = combination[:international_address]
        expect(address_settings_form).to be_valid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      expect(address_settings_form.submit).to be_falsey
    end

    it "sets draft question with the answer settings in it" do
      address_settings_form.uk_address = "true"
      address_settings_form.international_address = "true"
      address_settings_form.submit
      expect(address_settings_form.draft_question.answer_settings).to include({ input_type: { international_address: "true", uk_address: "true" } })
    end
  end
end
