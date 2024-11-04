require "rails_helper"

RSpec.describe Pages::LongListsSelection::BulkOptionsInput, type: :model do
  let(:bulk_options_input) { build :bulk_options_input, draft_question: }
  let(:only_one_option) { "true" }
  let(:draft_question) { build :draft_question, answer_type: "selection", answer_settings: { only_one_option: } }

  it "has a valid factory" do
    expect(bulk_options_input).to be_valid
  end

  describe "validations" do
    it "is invalid if fewer than 2 Bulk selection options are provided" do
      bulk_options_input.bulk_selection_options = "A single option"
      error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/bulk_options_input.attributes.bulk_selection_options.minimum")
      expect(bulk_options_input).not_to be_valid

      expect(bulk_options_input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
    end

    it "is invalid if more than 1000 Bulk selection options are provided" do
      bulk_options_input.bulk_selection_options = (1..1001).to_a.join("\n")
      error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/bulk_options_input.attributes.bulk_selection_options.maximum")
      expect(bulk_options_input).not_to be_valid

      expect(bulk_options_input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
    end

    it "is valid if there are between 2 and 1000 unique selection values" do
      bulk_options_input.bulk_selection_options = (1..2).to_a.join("\n")

      expect(bulk_options_input).to be_valid
      expect(bulk_options_input.errors.full_messages_for(:bulk_selection_options)).to be_empty

      bulk_options_input.bulk_selection_options = (1..1000).to_a.join("\n")

      expect(bulk_options_input).to be_valid
      expect(bulk_options_input.errors.full_messages_for(:bulk_selection_options)).to be_empty
    end

    it "is invalid if there are duplicate values" do
      bulk_options_input.bulk_selection_options = "1\n2\n2"
      error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/bulk_options_input.attributes.bulk_selection_options.uniqueness", duplicate: "2")
      expect(bulk_options_input).not_to be_valid

      expect(bulk_options_input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(bulk_options_input).to be_invalid
      end
    end

    context "when include_none_of_the_above is not 'true' or 'false'" do
      let(:bulk_options_input) { build :bulk_options_input, include_none_of_the_above: nil }

      it "is invalid" do
        error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/bulk_options_input.attributes.include_none_of_the_above.inclusion")
        expect(bulk_options_input).to be_invalid
        expect(bulk_options_input.errors.full_messages_for(:include_none_of_the_above)).to include("Include none of the above #{error_message}")
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      bulk_options_input.bulk_selection_options = ""
      expect(bulk_options_input.submit).to be_falsey
    end

    it "filters out blank inputs" do
      bulk_options_input.bulk_selection_options = "1\n\n2"
      bulk_options_input.include_none_of_the_above = "true"
      bulk_options_input.submit

      expect(bulk_options_input.draft_question.answer_settings[:selection_options]).to eq([{ name: "1" }, { name: "2" }])
    end

    context "when only one option is allowed" do
      let(:only_one_option) { "true" }

      it "sets draft_question answer_settings and is_optional" do
        bulk_options_input.bulk_selection_options = (1..2).to_a.join("\n")
        bulk_options_input.include_none_of_the_above = "true"
        bulk_options_input.submit

        expected_settings = {
          only_one_option:,
          selection_options: [{ name: "1" }, { name: "2" }],
        }

        expect(bulk_options_input.draft_question.answer_settings).to include(expected_settings)
        expect(bulk_options_input.draft_question.is_optional).to be(true)
      end
    end

    context "when more than one option is allowed" do
      let(:only_one_option) { "false" }

      it "sets draft_question answer_settings and is_optional" do
        bulk_options_input.bulk_selection_options = (1..2).to_a.join("\n")
        bulk_options_input.include_none_of_the_above = "true"
        bulk_options_input.submit

        expected_settings = {
          only_one_option:,
          selection_options: [{ name: "1" }, { name: "2" }],
        }

        expect(bulk_options_input.draft_question.answer_settings).to include(expected_settings)
        expect(bulk_options_input.draft_question.is_optional).to be(true)
      end
    end
  end

  describe "#none_of_the_above_options" do
    it "returns true and false as options" do
      expect(bulk_options_input.none_of_the_above_options).to eq [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
    end
  end
end
