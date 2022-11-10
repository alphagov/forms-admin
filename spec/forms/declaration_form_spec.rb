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

    it "is valid if declaration text is blank" do
      declaration_form = described_class.new(declaration_text: "")

      expect(declaration_form).to be_valid
    end

    context "when the task status feature is not enabled", feature_task_list_statuses: false do
      it "is valid if mark complete is blank" do
        declaration_form = described_class.new(mark_complete: "")

        expect(declaration_form).to be_valid
        expect(declaration_form.errors.full_messages_for(:mark_complete)).not_to include "Mark complete #{I18n.t('activemodel.errors.models.forms/declaration_form.attributes.mark_complete.blank')}"
      end
    end

    context "when the task status feature is enabled", feature_task_list_statuses: true do
      it "is not valid if mark complete is blank" do
        declaration_form = described_class.new(mark_complete: nil)

        expect(declaration_form).not_to be_valid
        expect(declaration_form.errors.full_messages_for(:mark_complete)).to include "Mark complete #{I18n.t('activemodel.errors.models.forms/declaration_form.attributes.mark_complete.blank')}"
      end
    end
  end

  describe "#submit" do
    it "returns false if the data is invalid" do
      form = described_class.new(declaration_text: ("abc" * 2001), form: { declaration_text: "" })
      expect(form.submit).to eq false
    end

    context "when the task status feature is not enabled", feature_task_list_statuses: false do
      it "sets the form's attribute value" do
        form = OpenStruct.new(declaration_text: "abc")
        declaration_form = described_class.new(form:, declaration_text: "new declaration text")
        declaration_form.submit
        expect(declaration_form.form.declaration_text).to eq "new declaration text"
      end
    end

    context "when the task status feature is enabled", feature_task_list_statuses: true do
      it "sets the form's attribute values" do
        form = OpenStruct.new(declaration_text: "abc", declaration_section_completed: "false")
        declaration_form = described_class.new(form:, declaration_text: "new declaration text", mark_complete: "true")
        declaration_form.submit
        expect(declaration_form.form.declaration_text).to eq "new declaration text"
        expect(declaration_form.form.declaration_section_completed).to eq "true"
      end
    end
  end
end
