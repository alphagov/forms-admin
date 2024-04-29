require "rails_helper"

RSpec.describe Forms::DeclarationInput, type: :model do
  describe "validations" do
    describe "Character length" do
      it "is valid if less than 2000 characters" do
        declaration_input = described_class.new(declaration_text: "a", mark_complete: true)

        expect(declaration_input).to be_valid
      end

      it "is valid if 2000 characters" do
        declaration_input = described_class.new(declaration_text: "a" * 2000, mark_complete: true)

        expect(declaration_input).to be_valid
      end

      it "is invalid if more than 2000 characters" do
        declaration_input = described_class.new(declaration_text: "a" * 2001, mark_complete: true)
        error_message = I18n.t("activemodel.errors.models.forms/declaration_input.attributes.declaration_text.too_long")

        expect(declaration_input).not_to be_valid

        declaration_input.validate(:declaration_text)

        expect(declaration_input.errors.full_messages_for(:declaration_text)).to include(
          "Declaration text #{error_message}",
        )
      end
    end

    it "is valid if declaration text is blank" do
      declaration_input = described_class.new(declaration_text: "", mark_complete: true)

      expect(declaration_input).to be_valid
    end

    it "is not valid if mark complete is blank" do
      declaration_input = described_class.new(mark_complete: nil)

      expect(declaration_input).not_to be_valid
      expect(declaration_input.errors.full_messages_for(:mark_complete)).to include "Mark complete #{I18n.t('activemodel.errors.models.forms/declaration_input.attributes.mark_complete.blank')}"
    end
  end

  describe "#submit" do
    it "returns false if the data is invalid" do
      form = described_class.new(declaration_text: ("abc" * 2001), form: { declaration_text: "" })
      expect(form.submit).to eq false
    end

    it "sets the form's attribute values" do
      form = OpenStruct.new(declaration_text: "abc", declaration_section_completed: "false")
      declaration_input = described_class.new(form:, declaration_text: "new declaration text", mark_complete: "true")
      declaration_input.submit
      expect(declaration_input.form.declaration_text).to eq "new declaration text"
      expect(declaration_input.form.declaration_section_completed).to eq "true"
    end
  end
end
