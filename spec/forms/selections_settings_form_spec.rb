require "rails_helper"

RSpec.describe Forms::SelectionsSettingsForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:selections_settings_form) { described_class.new }

  it "has a valid factory" do
    selections_settings_form = build :selections_settings_form
    expect(selections_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if fewer than 2 selection options are provided" do
      selections_settings_form.selection_options = []
      error_message = I18n.t("activemodel.errors.models.forms/selections_settings_form.attributes.selection_options.minimum")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if more than 20 selection options are provided" do
      selections_settings_form.selection_options = (1..21).to_a.map { |i| Forms::SelectionOption.new({ name: i.to_s }) }
      error_message = I18n.t("activemodel.errors.models.forms/selections_settings_form.attributes.selection_options.maximum")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is invalid if selection options are not unique" do
      selections_settings_form.selection_options = [Forms::SelectionOption.new({ name: "option 1" }), Forms::SelectionOption.new({ name: "option 2" }), Forms::SelectionOption.new({ name: "option 1" })]
      error_message = I18n.t("activemodel.errors.models.forms/selections_settings_form.attributes.selection_options.uniqueness")
      expect(selections_settings_form).not_to be_valid

      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to include("Selection options #{error_message}")
    end

    it "is valid if there are between 2 and 20 unique selection values" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Forms::SelectionOption.new({ name: i.to_s }) }

      expect(selections_settings_form).to be_valid
      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to be_empty

      selections_settings_form.selection_options = (1..20).to_a.map { |i| Forms::SelectionOption.new({ name: i.to_s }) }

      expect(selections_settings_form).to be_valid
      expect(selections_settings_form.errors.full_messages_for(:selection_options)).to be_empty
    end
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      expect(selections_settings_form.submit(session_mock)).to be_falsey
    end

    it "sets a session key called 'page' as a hash with the answer type in it" do
      selections_settings_form.selection_options = (1..2).to_a.map { |i| Forms::SelectionOption.new({ name: i.to_s }) }
      selections_settings_form.submit(session_mock)
      expect(session_mock[:page][:answer_settings].to_json).to eq({ only_one_option: nil, selection_options: [Forms::SelectionOption.new(name: "1"), Forms::SelectionOption.new(name: "2")] }.to_json)
    end
  end
end
