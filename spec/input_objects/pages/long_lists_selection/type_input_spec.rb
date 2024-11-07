require "rails_helper"

RSpec.describe Pages::LongListsSelection::TypeInput do
  subject(:input) { described_class.new(draft_question:, only_one_option:) }

  let(:draft_question) { build :draft_question, answer_type: "selection" }
  let(:only_one_option) { nil }

  describe "validations" do
    context "when only_one_option is blank" do
      let(:only_one_option) { nil }

      it "is invalid" do
        expect(input).not_to be_valid
        expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/type_input.attributes.only_one_option.inclusion")
        expect(input.errors.full_messages_for(:only_one_option)).to include("Only one option #{expected_message}")
      end
    end

    context "when only_one_option value is not in allowed values" do
      let(:only_one_option) { "foo" }

      it "is invalid" do
        expect(input).not_to be_valid
        expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/type_input.attributes.only_one_option.inclusion")
        expect(input.errors.full_messages_for(:only_one_option)).to include("Only one option #{expected_message}")
      end
    end

    context "when only_one_option is true" do
      let(:only_one_option) { "true" }

      it "is valid" do
        expect(input).to be_valid
      end
    end

    context "when only_one_option is false" do
      let(:only_one_option) { "false" }

      it "is valid" do
        expect(input).to be_valid
      end
    end
  end

  describe "#submit" do
    context "when input is invalid" do
      let(:only_one_option) { nil }

      it "returns false" do
        expect(input.submit).to be false
      end
    end

    context "when input is valid" do
      let(:only_one_option) { "true" }

      it "sets only_one_option in draft_question answer_settings" do
        input.submit
        expect(draft_question.answer_settings).to include(only_one_option: "true")
      end

      context "when there are existing answer settings" do
        before do
          draft_question.answer_settings = { foo: "bar" }
        end

        it "does not overwrite other answer_settings" do
          input.submit
          expect(draft_question.answer_settings).to include({ only_one_option: "true", foo: "bar" })
        end
      end
    end
  end
end
