require "rails_helper"

RSpec.describe Forms::DeclarationForm, type: :model do
  describe "validations" do
    describe "Character length" do
      it "is valid if less than 2000 characters" do
        declaration_form = described_class.new(declaration_text: "a")

        expect(declaration_form).to be_valid
      end

      it "is valid if 2000 characters" do
        declaration_form = described_class.new(declaration_text: "a" * 2000)

        expect(declaration_form).to be_valid
      end

      it "is invalid if more than 2000 characters" do
        declaration_form = described_class.new(declaration_text: "a" * 2001)
        error_message = I18n.t("activemodel.errors.models.forms/declaration_form.attributes.declaration_text.too_long")

        expect(declaration_form).not_to be_valid

        declaration_form.validate(:declaration_text)

        expect(declaration_form.errors.full_messages_for(:declaration_text)).to include(
          "Declaration text #{error_message}",
        )
      end
    end

    it "is valid if blank" do
      declaration_form = described_class.new(declaration_text: "")

      expect(declaration_form).to be_valid
    end
  end

  describe "#submit" do
    it "returns false if the data is invalid" do
      form = described_class.new(declaration_text: ("abc" * 2001), form: { declaration_text: "" })
      expect(form.submit).to eq false
    end

    it "sets the form's attribute value" do
      form = OpenStruct.new(declaration_text: "abc")
      declaration_form = described_class.new(form:)
      declaration_form.declaration_text = "new declaration text"
      declaration_form.submit
      expect(declaration_form.form.declaration_text).to eq "new declaration text"
    end
  end
end
