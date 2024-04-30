require "rails_helper"

RSpec.describe Pages::NameSettingsInput, type: :model do
  let(:name_settings_input) { build :name_settings_input, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "name", form_id: 1 }

  it "has a valid factory" do
    expect(name_settings_input).to be_valid
  end

  describe "validations" do
    it "is invalid if no input_type is selected" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_input.attributes.input_type.blank")
      name_settings_input.input_type = nil
      expect(name_settings_input).to be_invalid
      expect(name_settings_input.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid if no title_needed is selected" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_input.attributes.title_needed.blank")
      name_settings_input.title_needed = nil
      expect(name_settings_input).to be_invalid
      expect(name_settings_input.errors.full_messages_for(:title_needed)).to include("Title needed #{error_message}")
    end

    it "is invalid if input_type is given a value which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_input.attributes.input_type.inclusion")

      name_settings_input.input_type = "username"
      expect(name_settings_input).to be_invalid
      expect(name_settings_input.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid if title_needed is given a value which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_input.attributes.title_needed.inclusion")

      name_settings_input.title_needed = "maybe"
      expect(name_settings_input).to be_invalid
      expect(name_settings_input.errors.full_messages_for(:title_needed)).to include("Title needed #{error_message}")
    end

    it "is valid if name settings are valid" do
      valid_combinations = [
        { input_type: "full_name", title_needed: "true" },
        { input_type: "first_and_last_name", title_needed: "true" },
        { input_type: "first_middle_and_last_name", title_needed: "true" },
        { input_type: "full_name", title_needed: "false" },
        { input_type: "first_and_last_name", title_needed: "false" },
        { input_type: "first_middle_and_last_name", title_needed: "false" },
      ]
      valid_combinations.each do |combination|
        name_settings_input.input_type = combination[:input_type]
        name_settings_input.title_needed = combination[:title_needed]
        expect(name_settings_input).to be_valid
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(name_settings_input).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(name_settings_input).to receive(:invalid?).and_return(true)
      expect(name_settings_input.submit).to be_falsey
    end

    it "sets draft_question answer_settings" do
      name_settings_input.input_type = "full_name"
      name_settings_input.title_needed = "true"
      name_settings_input.submit

      expected_settings = {
        input_type: "full_name",
        title_needed: "true",
      }

      expect(name_settings_input.draft_question.answer_settings).to include(expected_settings)
    end
  end
end
