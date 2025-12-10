require "rails_helper"

RSpec.describe Pages::Selection::BulkOptionsInput, type: :model do
  subject(:input) { build :bulk_options_input, draft_question:, include_none_of_the_above: }

  let(:form) { create :form }
  let(:include_none_of_the_above) { "true" }
  let(:only_one_option) { "true" }
  let(:answer_settings) { { only_one_option: } }
  let(:is_optional) { nil }
  let(:draft_question) { create :draft_question, answer_type: "selection", answer_settings:, form_id: form.id, is_optional: }

  it "has a valid factory" do
    expect(input).to be_valid
  end

  describe "validations" do
    it "is invalid if fewer than 2 Bulk selection options are provided" do
      input.bulk_selection_options = "A single option"
      error_message = I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.bulk_selection_options.minimum")
      expect(input).not_to be_valid

      expect(input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
    end

    context "when only_one_option is true for the draft_question" do
      let(:only_one_option) { "true" }

      it "is valid if there are between 2 and 1000 unique selection values" do
        input.bulk_selection_options = (1..2).to_a.join("\n")

        expect(input).to be_valid
        expect(input.errors.full_messages_for(:bulk_selection_options)).to be_empty

        input.bulk_selection_options = (1..1000).to_a.join("\n")

        expect(input).to be_valid
        expect(input.errors.full_messages_for(:bulk_selection_options)).to be_empty
      end

      it "is invalid if more than 1000 Bulk selection options are provided" do
        input.bulk_selection_options = (1..1001).to_a.join("\n")
        error_message = I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.bulk_selection_options.maximum_choose_only_one_option")
        expect(input).not_to be_valid

        expect(input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
      end
    end

    context "when only_one_option is false for the draft_question" do
      let(:only_one_option) { "false" }

      it "is valid if there are between 2 and 30 unique selection values" do
        input.bulk_selection_options = (1..2).to_a.join("\n")

        expect(input).to be_valid
        expect(input.errors.full_messages_for(:bulk_selection_options)).to be_empty

        input.bulk_selection_options = (1..30).to_a.join("\n")

        expect(input).to be_valid
        expect(input.errors.full_messages_for(:bulk_selection_options)).to be_empty
      end

      it "is invalid if more than 30 Bulk selection options are provided" do
        input.bulk_selection_options = (1..31).to_a.join("\n")
        error_message = I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.bulk_selection_options.maximum_choose_more_than_one_option")
        expect(input).not_to be_valid

        expect(input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
      end
    end

    it "is invalid if there are duplicate values" do
      input.bulk_selection_options = "1\n2\n2"
      error_message = I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.bulk_selection_options.uniqueness", duplicate: "2")
      expect(input).not_to be_valid

      expect(input.errors.full_messages_for(:bulk_selection_options)).to include("Bulk selection options #{error_message}")
    end

    context "when include_none_of_the_above is not 'true' or 'false'" do
      let(:bulk_options_input) { build :bulk_options_input, include_none_of_the_above: nil, draft_question: }
      subject(:input) { build :bulk_options_input, include_none_of_the_above: nil, draft_question: }

      it "is invalid" do
        error_message = I18n.t("activemodel.errors.models.pages/selection/bulk_options_input.attributes.include_none_of_the_above.inclusion")
        expect(bulk_options_input).to be_invalid
        expect(bulk_options_input.errors.full_messages_for(:include_none_of_the_above)).to include("Include none of the above #{error_message}")
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      input.bulk_selection_options = ""
      expect(input.submit).to be_falsey
    end

    it "filters out blank inputs" do
      input.bulk_selection_options = "1\n\n2"
      input.submit

      expect(input.draft_question.answer_settings[:selection_options]).to eq([{ name: "1" }, { name: "2" }])
    end

    it "logs submission" do
      allow(Rails.logger).to receive(:info)

      input.bulk_selection_options = (1..2).to_a.join("\n")
      input.submit

      expect(Rails.logger).to have_received(:info).with("Submitted selection options for a selection question", {
        "is_bulk_entry": true,
        "options_count": 2,
        "only_one_option": true,
      })
    end

    context "when only one option is allowed" do
      let(:only_one_option) { "true" }

      it "sets draft_question answer_settings and is_optional" do
        input.bulk_selection_options = (1..2).to_a.join("\n")
        input.submit

        expected_settings = {
          only_one_option:,
          selection_options: [{ name: "1" }, { name: "2" }],
        }

        expect(input.draft_question.answer_settings).to include(expected_settings)
        expect(input.draft_question.is_optional).to be(true)
      end
    end

    context "when more than one option is allowed" do
      let(:only_one_option) { "false" }

      it "sets draft_question answer_settings and is_optional" do
        input.bulk_selection_options = (1..2).to_a.join("\n")
        input.submit

        expected_settings = {
          only_one_option:,
          selection_options: [{ name: "1" }, { name: "2" }],
        }

        expect(input.draft_question.answer_settings).to include(expected_settings)
        expect(input.draft_question.is_optional).to be(true)
      end
    end
  end

  it_behaves_like "base selection options input"
end
