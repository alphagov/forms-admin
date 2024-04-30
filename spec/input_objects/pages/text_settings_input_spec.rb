require "rails_helper"

RSpec.describe Pages::TextSettingsInput, type: :model do
  let(:text_settings_input) { build :text_settings_input, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "text", form_id: 1 }

  it "has a valid factory" do
    expect(text_settings_input).to be_valid
  end

  describe "validations" do
    it "is invalid if not given an input type" do
      error_message = I18n.t("activemodel.errors.models.pages/text_settings_input.attributes.input_type.blank")
      text_settings_input.input_type = nil
      expect(text_settings_input).to be_invalid
      expect(text_settings_input.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an empty string input_type" do
      error_message = I18n.t("activemodel.errors.models.pages/text_settings_input.attributes.input_type.blank")
      text_settings_input.input_type = ""
      expect(text_settings_input).to be_invalid
      expect(text_settings_input.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an input_type which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/text_settings_input.attributes.input_type.inclusion")
      text_settings_input.input_type = "some_random_string"
      expect(text_settings_input).to be_invalid
      expect(text_settings_input.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is valid if input type is a valid input type" do
      described_class::INPUT_TYPES.each do |input_type|
        text_settings_input.input_type = input_type
        expect(text_settings_input).to be_valid "#{input_type} is not an input type"
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(text_settings_input).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      allow(text_settings_input).to receive(:invalid?).and_return(true)
      expect(text_settings_input.submit).to be_falsey
    end

    it "sets draft_question answer_settings" do
      text_settings_input.input_type = "single_line"
      text_settings_input.submit

      expected_settings = {
        input_type: "single_line",
      }

      expect(text_settings_input.draft_question.answer_settings).to include(expected_settings)
    end
  end
end
