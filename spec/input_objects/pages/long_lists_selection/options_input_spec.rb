require "rails_helper"

RSpec.describe Pages::LongListsSelection::OptionsInput do
  let(:only_one_option) { "true" }
  let(:draft_question) { build :draft_question, answer_type: "selection", answer_settings: { only_one_option: } }
  let(:selection_options) { [{ name: "option 1" }, { name: "option 2" }] }

  describe "validations" do
    describe "include_none_of_the_above" do
      it "is invalid if include_none_of_the_above is blank" do
        input = described_class.new(draft_question:, include_none_of_the_above: nil, selection_options:)
        expect(input).not_to be_valid
        expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.include_none_of_the_above.inclusion")
        expect(input.errors.full_messages_for(:include_none_of_the_above)).to include("Include none of the above #{expected_message}")
      end

      it "is invalid if include_none_of_the_above value is not in allowed values" do
        input = described_class.new(draft_question:, include_none_of_the_above: "foo", selection_options:)
        expect(input).not_to be_valid
        expected_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.include_none_of_the_above.inclusion")
        expect(input.errors.full_messages_for(:include_none_of_the_above)).to include("Include none of the above #{expected_message}")
      end

      it "is valid if include_none_of_the_above is true" do
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        expect(input).to be_valid
      end

      it "is valid if include_none_of_the_above is false" do
        input = described_class.new(draft_question:, include_none_of_the_above: "false", selection_options:)
        expect(input).to be_valid
      end
    end

    describe "selection_options" do
      it "is invalid if fewer than 2 selection options are provided" do
        selection_options = []
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.selection_options.minimum")
        expect(input).not_to be_valid

        expect(input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
      end

      it "is invalid if selection options are not unique" do
        selection_options = [{ name: "option 1" }, { name: "option 2" }, { name: "option 1" }]
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.selection_options.uniqueness")
        expect(input).not_to be_valid

        expect(input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
      end

      it "is valid if there are 2 unique selection values" do
        selection_options = (1..2).to_a.map { |i| { name: i.to_s } }
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)

        expect(input).to be_valid
      end

      context "when only_one_option is true for the draft_question" do
        it "is invalid if more than 1000 selection options are provided" do
          selection_options = (1..1001).to_a.map { |i| OpenStruct.new(name: i.to_s) }
          input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
          error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.selection_options.maximum_choose_only_one_option")
          expect(input).not_to be_valid

          expect(input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
        end

        it "is valid if there are 1000 unique selection values" do
          selection_options = (1..1000).to_a.map { |i| { name: i.to_s } }
          input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)

          expect(input).to be_valid
        end
      end

      context "when only_one_option is false for the draft_question" do
        let(:only_one_option) { "false" }

        it "is invalid if more than 30 selection options are provided" do
          selection_options = (1..31).to_a.map { |i| OpenStruct.new(name: i.to_s) }
          input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
          error_message = I18n.t("activemodel.errors.models.pages/long_lists_selection/options_input.attributes.selection_options.maximum_choose_more_than_one_option")
          expect(input).not_to be_valid

          expect(input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
        end

        it "is valid if there are 30 unique selection values" do
          selection_options = (1..30).to_a.map { |i| { name: i.to_s } }
          input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)

          expect(input).to be_valid
        end
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      input = described_class.new(draft_question:, include_none_of_the_above: nil, selection_options:)
      expect(input.submit).to be false
    end

    it "sets draft_question answer_settings and is_optional" do
      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
      input.submit

      expect(input.draft_question.answer_settings).to include(selection_options:)
    end

    it "sets draft_question is_optional" do
      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)

      expect { input.submit }.to change(draft_question, :is_optional).to true
    end

    it "logs submission" do
      allow(Rails.logger).to receive(:info)

      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
      input.submit

      expect(Rails.logger).to have_received(:info).with("Submitted selection options for a selection question", {
        "is_bulk_entry": false,
        "options_count": 2,
        "only_one_option": true,
      })
    end

    context "when there are existing answer settings" do
      before do
        draft_question.answer_settings = { foo: "bar" }
      end

      it "does not overwrite other answer_settings" do
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        input.submit
        expect(draft_question.answer_settings).to include({ selection_options:, foo: "bar" })
      end
    end
  end

  describe "#add_another" do
    it "adds an empty item to the end of the selection options array" do
      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
      input.add_another

      expect(input.selection_options).to eq([{ name: "option 1" }, { name: "option 2" }, { name: "" }])
    end
  end

  describe "#remove" do
    it "removes the specified option from the selection options array" do
      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
      input.remove(1)

      expect(input.selection_options.to_json).to eq([{ name: "option 1" }].to_json)
    end
  end

  describe "#filter_out_blank_options" do
    it "filters out blank inputs" do
      selection_options = [{ name: "1" }, { name: "" }, { name: "2" }]
      input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
      input.validate

      expect(input.selection_options.to_json).to eq([{ name: "1" }, { name: "2" }].to_json)
    end
  end

  describe "#maximum_options" do
    context "when only_one_option is true for the draft_question" do
      it "returns 1000" do
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        expect(input.maximum_options).to eq 1000
      end
    end

    context "when only_one_option is false for the draft_question" do
      let(:only_one_option) { "false" }

      it "returns 30" do
        input = described_class.new(draft_question:, include_none_of_the_above: "true", selection_options:)
        expect(input.maximum_options).to eq 30
      end
    end
  end
end
