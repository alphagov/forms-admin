require "rails_helper"

RSpec.describe Forms::WelshTranslationInput, type: :model do
  describe "validations" do
    it "is not valid if mark complete is blank" do
      form = OpenStruct.new(welsh_completed: false, name: "Apply for a juggling licence")
      welsh_translation_input = described_class.new(mark_complete: nil, form:)

      expect(welsh_translation_input).not_to be_valid
      expect(welsh_translation_input.errors.full_messages_for(:mark_complete)).to include "Mark complete #{I18n.t('activemodel.errors.models.forms/welsh_translation_input.attributes.mark_complete.blank')}"
    end
  end

  describe "#submit" do
    it "returns false if the data is invalid" do
      form = OpenStruct.new(welsh_completed: false, name: "Apply for a juggling licence")
      welsh_translation_input = described_class.new(mark_complete: nil, form:)
      expect(welsh_translation_input.submit).to be false
    end

    it "sets the form's attribute values" do
      form = OpenStruct.new(welsh_completed: false, name: "Apply for a juggling licence")
      welsh_translation_input = described_class.new(form:, mark_complete: true)
      welsh_translation_input.submit
      expect(welsh_translation_input.form.welsh_completed).to be true
    end
  end
end
