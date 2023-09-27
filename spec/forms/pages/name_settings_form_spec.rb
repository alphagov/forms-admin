require "rails_helper"

RSpec.describe Pages::NameSettingsForm, type: :model do
  let(:form) { build :form, id: 1 }
  let(:name_settings_form) { described_class.new(draft_question:) }
  let(:draft_question) { build :draft_question, form_id: form.id, user: }
  let(:user) { build :user }

  it "has a valid factory" do
    name_settings_form = build :name_settings_form
    expect(name_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if no input_type is selected" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_form.attributes.input_type.blank")
      name_settings_form.input_type = nil
      expect(name_settings_form).to be_invalid
      expect(name_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid if no title_needed is selected" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_form.attributes.title_needed.blank")
      name_settings_form.title_needed = nil
      expect(name_settings_form).to be_invalid
      expect(name_settings_form.errors.full_messages_for(:title_needed)).to include("Title needed #{error_message}")
    end

    it "is invalid if input_type is given a value which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_form.attributes.input_type.inclusion")

      name_settings_form.input_type = "username"
      expect(name_settings_form).to be_invalid
      expect(name_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid if title_needed is given a value which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/name_settings_form.attributes.title_needed.inclusion")

      name_settings_form.title_needed = "maybe"
      expect(name_settings_form).to be_invalid
      expect(name_settings_form.errors.full_messages_for(:title_needed)).to include("Title needed #{error_message}")
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
        name_settings_form.input_type = combination[:input_type]
        name_settings_form.title_needed = combination[:title_needed]
        expect(name_settings_form).to be_valid
      end
    end
  end

  describe "#submit" do
    it "returns false if the form is invalid" do
      expect(name_settings_form.submit).to be_falsey
    end

    it "sets draft question answer settings in it" do
      name_settings_form = build(:name_settings_form, draft_question:)
      name_settings_form.submit
      expect(draft_question.answer_settings).to include(input_type: "full_name")
      expect(draft_question.answer_settings).to include(title_needed: "true")
    end
  end
end
