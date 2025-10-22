require "rails_helper"

RSpec.describe Forms::WelshTranslationInput, type: :model do
  describe "#submit" do
    it "sets the form's attribute values" do
      form = OpenStruct.new(welsh_completed: false, name: "Apply for a juggling licence")
      welsh_translation_input = described_class.new(form:, mark_complete: true)
      welsh_translation_input.submit
      expect(welsh_translation_input.form.welsh_completed).to be true
    end
  end
end
