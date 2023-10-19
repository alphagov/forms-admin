require "rails_helper"

RSpec.describe Pages::DateSettingsForm, type: :model do
  let(:date_settings_form) { build :date_settings_form, draft_question: }
  let(:draft_question) { build :draft_question, answer_type: "date", form_id: 1 }

  it "has a valid factory" do
    expect(date_settings_form).to be_valid
  end

  describe "validations" do
    it "is invalid if not given an input type" do
      error_message = I18n.t("activemodel.errors.models.pages/date_settings_form.attributes.input_type.blank")
      date_settings_form.input_type = nil
      expect(date_settings_form).to be_invalid
      expect(date_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an empty string input_type" do
      error_message = I18n.t("activemodel.errors.models.pages/date_settings_form.attributes.input_type.blank")
      date_settings_form.input_type = ""
      expect(date_settings_form).to be_invalid
      expect(date_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is invalid given an input_type which is not in the list" do
      error_message = I18n.t("activemodel.errors.models.pages/date_settings_form.attributes.input_type.inclusion")
      date_settings_form.input_type = "some_random_string"
      expect(date_settings_form).to be_invalid
      expect(date_settings_form.errors.full_messages_for(:input_type)).to include("Input type #{error_message}")
    end

    it "is valid if input type is a valid input type" do
      described_class::INPUT_TYPES.each do |input_type|
        date_settings_form.input_type = input_type
        expect(date_settings_form).to be_valid "#{input_type} is not an input type"
      end
    end

    context "when not given a draft_question" do
      let(:draft_question) { nil }

      it "is invalid" do
        expect(date_settings_form).to be_invalid
      end
    end
  end

  describe "#submit" do
    let(:session_mock) { {} }

    it "returns false if the form is invalid" do
      allow(date_settings_form).to receive(:invalid?).and_return(true)
      expect(date_settings_form.submit(session_mock)).to be_falsey
    end

    it "sets a session key called 'page' as a hash with the answer type in it" do
      date_settings_form.input_type = "date_of_birth"
      date_settings_form.submit(session_mock)
      expect(session_mock[:page][:answer_settings]).to include(input_type: "date_of_birth")
    end

    it "sets draft_question answer_settings" do
      date_settings_form.input_type = "date_of_birth"
      date_settings_form.submit(session_mock)

      expected_settings = {
        input_type: "date_of_birth",
      }.with_indifferent_access

      expect(date_settings_form.draft_question.answer_settings).to include(expected_settings)
    end
  end
end
