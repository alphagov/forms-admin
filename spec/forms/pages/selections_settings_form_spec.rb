require "rails_helper"

RSpec.describe Pages::SelectionsSettingsForm, type: :model do
  let(:selections_settings_form) { described_class.new(draft_question:) }
  let(:draft_question) { build :draft_question, form_id: 1, user: }
  let(:user) { build :user }

  it "has a valid factory" do
    selections_settings_form = build :selections_settings_form
    expect(selections_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if fewer than 2 selection options are provided" do
      selections_settings_form.selection_options = []
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_form.attributes.selection_options.minimum")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if more than 20 selection options are provided" do
      selections_settings_form.selection_options = (1..21).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_form.attributes.selection_options.maximum")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if selection options are not unique" do
      selections_settings_form.selection_options = [Pages::SelectionOption.new({ name: "option 1" }), Pages::SelectionOption.new({ name: "option 2" }), Pages::SelectionOption.new({ name: "option 1" })]
      error_message = I18n.t("activemodel.errors.models.pages/selections_settings_form.attributes.selection_options.uniqueness")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is valid if there are between 2 and 20 unique selection values" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }

      expect(selections_settings_form).to be_valid
      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to be_empty

      selections_settings_form.selection_options = (1..20).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }

      expect(selections_settings_form).to be_valid
      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to be_empty
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      selections_settings_form.selection_options = []
      expect(selections_settings_form.submit).to be_falsey
    end

    it "sets draft question with the correct answer settings" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }
      selections_settings_form.only_one_option = true
      selections_settings_form.include_none_of_the_above = true
      selections_settings_form.submit
      expect(selections_settings_form.draft_question.answer_settings.to_json).to include({ only_one_option: true,
                                                                                           selection_options: [
                                                                                             Pages::SelectionOption.new(name: "1"), Pages::SelectionOption.new(name: "2")
                                                                                           ] }.to_json)
      expect(selections_settings_form.draft_question.is_optional).to eq(true)
    end
  end

  describe "add_another" do
    it "adds an empty item to the end of the selection options array" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }
      selections_settings_form.add_another

      expect(selections_settings_form.selection_options.to_json).to eq([Pages::SelectionOption.new(name: "1"), Pages::SelectionOption.new(name: "2"), Pages::SelectionOption.new(name: "")].to_json)
    end
  end

  describe "remove" do
    it "removes the specified option from the selection options array" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }
      selections_settings_form.remove(1)

      expect(selections_settings_form.selection_options.to_json).to eq([Pages::SelectionOption.new(name: "1")].to_json)
    end
  end

  describe "answer_settings" do
    it "returns the correct answer_settings object" do
      selection_options = (1..2).to_a.map { |i| Pages::SelectionOption.new({ name: i.to_s }) }
      only_one_option = true
      selections_settings_form.selection_options = selection_options
      selections_settings_form.only_one_option = only_one_option

      expect(selections_settings_form.answer_settings).to eq(selection_options:, only_one_option:)
    end
  end

  describe "filter_out_blank_options" do
    it "filters out blank inputs" do
      selections_settings_form.selection_options = [Pages::SelectionOption.new(name: "1"), Pages::SelectionOption.new(name: ""), Pages::SelectionOption.new(name: "2")]
      selections_settings_form.filter_out_blank_options

      expect(selections_settings_form.selection_options.to_json).to eq([Pages::SelectionOption.new(name: "1"), Pages::SelectionOption.new(name: "2")].to_json)
    end
  end
end
