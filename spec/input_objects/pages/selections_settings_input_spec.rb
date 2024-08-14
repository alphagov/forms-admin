require "rails_helper"

RSpec.describe Pages::SelectionsSettingsInput, type: :model do
  let(:selections_settings_input) { build :selections_settings_input, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "selection" }

  it "has a valid factory" do
    expect(selections_settings_input).to be_valid
  end

  describe "validations" do
    it "is invalid if fewer than 2 selection options are provided" do
      selections_settings_input.selection_options = []
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_input.attributes.selection_options.minimum")
      expect(selections_settings_input).not_to be_valid

      expect(selections_settings_input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if more than 20 selection options are provided" do
      selections_settings_input.selection_options = (1..31).to_a.map { |i| OpenStruct.new(name: i.to_s) }
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_input.attributes.selection_options.maximum")
      expect(selections_settings_input).not_to be_valid

      expect(selections_settings_input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if selection options are not unique" do
      selections_settings_input.selection_options = [{ name: "option 1" }, { name: "option 2" }, { name: "option 1" }]
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_input.attributes.selection_options.uniqueness")
      expect(selections_settings_input).not_to be_valid

      expect(selections_settings_input.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is valid if there are between 2 and 20 unique selection values" do
      selections_settings_input.selection_options = (1..2).to_a.map { |i| { name: i.to_s } }

      expect(selections_settings_input).to be_valid
      expect(selections_settings_input.errors.full_messages_for(:selection_options)).to be_empty

      selections_settings_input.selection_options = (1..20).to_a.map { |i| { name: i.to_s } }

      expect(selections_settings_input).to be_valid
      expect(selections_settings_input.errors.full_messages_for(:selection_options)).to be_empty
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(selections_settings_input).to be_invalid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      selections_settings_input.selection_options = []
      expect(selections_settings_input.submit).to be_falsey
    end

    it "sets draft_question answer_settings and is_optional" do
      selections_settings_input.selection_options = (1..2).to_a.map { |i| { name: i.to_s } }
      selections_settings_input.only_one_option = true
      selections_settings_input.include_none_of_the_above = true
      selections_settings_input.submit

      expected_settings = {
        only_one_option: true,
        selection_options: [{ name: "1" }, { name: "2" }],
      }

      expect(selections_settings_input.draft_question.answer_settings).to include(expected_settings)
      expect(selections_settings_input.draft_question.is_optional).to be(true)
    end
  end

  describe "add_another" do
    it "adds an empty item to the end of the selection options array" do
      selections_settings_input.selection_options = (1..2).to_a.map { |i| { name: i.to_s } }
      selections_settings_input.add_another

      expect(selections_settings_input.selection_options).to eq([{ name: "1" }, { name: "2" }, { name: "" }])
    end
  end

  describe "remove" do
    it "removes the specified option from the selection options array" do
      selections_settings_input.selection_options = (1..2).to_a.map { |i| { name: i.to_s } }
      selections_settings_input.remove(1)

      expect(selections_settings_input.selection_options.to_json).to eq([{ name: "1" }].to_json)
    end
  end

  describe "answer_settings" do
    it "returns the correct answer_settings object" do
      selection_options = (1..2).to_a.map { |i| { name: i.to_s } }
      only_one_option = true
      selections_settings_input.selection_options = selection_options
      selections_settings_input.only_one_option = only_one_option

      expect(selections_settings_input.answer_settings).to eq(selection_options:, only_one_option:)
    end
  end

  describe "filter_out_blank_options" do
    it "filters out blank inputs" do
      selections_settings_input.selection_options = [{ name: "1" }, { name: "" }, { name: "2" }]
      selections_settings_input.filter_out_blank_options

      expect(selections_settings_input.selection_options.to_json).to eq([{ name: "1" }, { name: "2" }].to_json)
    end
  end
end
