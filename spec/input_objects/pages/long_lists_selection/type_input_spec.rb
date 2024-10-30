require "rails_helper"

RSpec.describe Pages::LongListsSelection::TypeInput do
  let(:draft_question) { build :draft_question, answer_type: "selection" }

  describe "validations" do
    it "is invalid if only_one_option is blank" do
      input = described_class.new(draft_question:, only_one_option: nil)
      expect(input).not_to be_valid
      expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/type_input.attributes.only_one_option.inclusion")
      expect(input.errors.full_messages_for(:only_one_option)).to include("Only one option #{expected_message}")
    end

    it "is invalid if only_one_option value is not in allowed values" do
      input = described_class.new(draft_question:, only_one_option: "foo")
      expect(input).not_to be_valid
      expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/type_input.attributes.only_one_option.inclusion")
      expect(input.errors.full_messages_for(:only_one_option)).to include("Only one option #{expected_message}")
    end

    it "is valid if only_one_option is true" do
      input = described_class.new(draft_question:, only_one_option: "true")
      expect(input).to be_valid
    end

    it "is valid if only_one_option is false" do
      input = described_class.new(draft_question:, only_one_option: "false")
      expect(input).to be_valid
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      input = described_class.new(draft_question:, only_one_option: nil)
      expect(input.submit).to be false
    end

    it "sets only_one_option in draft_question answer_settings" do
      input = described_class.new(draft_question:, only_one_option: "true")
      input.submit
      expect(draft_question.answer_settings).to include(only_one_option: "true")
    end

    context "when there are existing answer settings" do
      before do
        draft_question.answer_settings = { foo: "bar" }
      end

      it "does not overwrite other answer_settings" do
        input = described_class.new(draft_question:, only_one_option: "true")
        input.submit
        expect(draft_question.answer_settings).to include({ only_one_option: "true", foo: "bar" })
      end
    end
  end
end
