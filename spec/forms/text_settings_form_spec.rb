require "rails_helper"

RSpec.describe Forms::TextSettingsForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:text_settings_form) { described_class.new }

  it "has a valid factory" do
    text_settings_form = build :text_settings_form
    expect(text_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if not given an input type" do
      error_message = I18n.t("activemodel.errors.models.forms/text_settings_form.attributes.input_type.blank")
      text_settings_form.input_type = nil
      expect(text_settings_form).to be_invalid
      expect(text_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an empty string input_type" do
      error_message = I18n.t("activemodel.errors.models.forms/text_settings_form.attributes.input_type.blank")
      text_settings_form.input_type = ""
      expect(text_settings_form).to be_invalid
      expect(text_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an input_type which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.forms/text_settings_form.attributes.input_type.inclusion")
      text_settings_form.input_type = "some_random_string"
      expect(text_settings_form).to be_invalid
      expect(text_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is valid if input type is a valid input type" do
      described_class::INPUT_TYPES.each do |input_type|
        text_settings_form.input_type = input_type
        expect(text_settings_form).to be_valid "#{input_type} is not an input type"
      end
    end
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      expect(text_settings_form.submit(session_mock)).to be_falsey
    end

    it "sets a session key called 'page' as a hash with the answer type in it" do
      text_settings_form.input_type = "single_line"
      text_settings_form.submit(session_mock)
      expect(session_mock[:page][:answer_settings]).to include(input_type: "single_line")
    end
  end
end
