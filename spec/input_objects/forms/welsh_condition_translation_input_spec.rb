require "rails_helper"

RSpec.describe Forms::WelshConditionTranslationInput, type: :model do
  subject(:welsh_condition_translation_input) { described_class.new(new_input_data) }

  let(:condition) { create_condition }
  let(:page) { create :page }

  let(:new_input_data) do
    {
      id: condition.id,
      answer_value_cy: "Ydw",
      exit_page_markdown_cy: "Nid ydych yn gymwys",
      exit_page_heading_cy: "Mae'n ddrwg gennym, nid ydych yn gymwys ar gyfer y gwasanaeth hwn.",
    }
  end

  def create_condition(attributes = {})
    default_attributes = {
      id: 1,
      answer_value: "Yes",
      exit_page_markdown: "You are ineligible",
      exit_page_heading: "Sorry, you are ineligible for this service.",
      answer_value_cy: "",
      exit_page_markdown_cy: "",
      exit_page_heading_cy: "",
    }
    create(:condition, default_attributes.merge(attributes))
  end

  describe "validations" do
    context "when the Welsh answer value is missing" do
      let(:new_input_data) { super().merge(answer_value_cy: nil) }

      context "when the form has an answer value in English" do
        it "is not valid" do
          expect(welsh_condition_translation_input).not_to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:answer_value_cy)).to include "Answer value cy #{I18n.t('activemodel.errors.models.forms/welsh_condition_translation_input.attributes.answer_value_cy.blank')}"
        end
      end

      context "when the form does not have an answer value in English" do
        let(:condition) { create_condition(answer_value: nil) }

        it "is valid" do
          expect(welsh_condition_translation_input).to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:answer_value_cy)).to be_empty
        end
      end
    end

    context "when the Welsh exit page heading is missing" do
      let(:new_input_data) { super().merge(exit_page_heading_cy: nil) }

      context "when the form has an exit page in English" do
        it "is not valid" do
          expect(welsh_condition_translation_input).not_to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:exit_page_heading_cy)).to include "Exit page heading cy #{I18n.t('activemodel.errors.models.forms/welsh_condition_translation_input.attributes.exit_page_heading_cy.blank')}"
        end
      end

      context "when the form does not have an exit page in English" do
        let(:condition) { create_condition(exit_page_heading: nil, exit_page_markdown: nil) }

        it "is valid" do
          expect(welsh_condition_translation_input).to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:exit_page_heading_cy)).to be_empty
        end
      end
    end

    context "when the Welsh exit page markdown is missing" do
      let(:new_input_data) { super().merge(exit_page_markdown_cy: nil) }

      context "when the form has an exit page in English" do
        it "is not valid" do
          expect(welsh_condition_translation_input).not_to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:exit_page_markdown_cy)).to include "Exit page markdown cy #{I18n.t('activemodel.errors.models.forms/welsh_condition_translation_input.attributes.exit_page_markdown_cy.blank')}"
        end
      end

      context "when the form does not have an exit page in English" do
        let(:condition) { create_condition(exit_page_heading: nil, exit_page_markdown: nil) }

        it "is valid" do
          expect(welsh_condition_translation_input).to be_valid
          expect(welsh_condition_translation_input.errors.full_messages_for(:exit_page_markdown_cy)).to be_empty
        end
      end
    end
  end

  describe "#submit" do
    it "returns true" do
      expect(welsh_condition_translation_input.submit).to be true
    end

    it "updates the condition's welsh attributes with the new values" do
      welsh_condition_translation_input.submit
      condition.reload

      expect(condition.reload.answer_value_cy).to eq(new_input_data[:answer_value_cy])
      expect(condition.reload.exit_page_markdown_cy).to eq(new_input_data[:exit_page_markdown_cy])
      expect(condition.reload.exit_page_heading_cy).to eq(new_input_data[:exit_page_heading_cy])
    end

    it "does not update any non-welsh attributes" do
      english_value_before = condition.answer_value
      welsh_condition_translation_input.submit
      expect(condition.reload.answer_value).to eq(english_value_before)
    end

    context "when the condition has no answer value" do
      let(:condition) { create_condition(answer_value: nil) }

      it "clears the Welsh answer value" do
        welsh_condition_translation_input.submit
        expect(condition.reload.answer_value_cy).to be_nil
      end
    end

    context "when the condition has no exit page markdown" do
      let(:condition) { create_condition(exit_page_markdown: nil) }

      it "clears the Welsh exit page markdown and heading" do
        welsh_condition_translation_input.submit
        expect(condition.reload.exit_page_markdown_cy).to be_nil
        expect(condition.reload.exit_page_heading_cy).to be_nil
      end
    end
  end

  describe "#assign_page_values" do
    it "loads the existing welsh attributes from the page" do
      welsh_condition_translation_input = described_class.new(id: condition.id)
      welsh_condition_translation_input.assign_condition_values

      expect(welsh_condition_translation_input.answer_value_cy).to eq(condition.answer_value_cy)
      expect(welsh_condition_translation_input.exit_page_markdown_cy).to eq(condition.exit_page_markdown_cy)
      expect(welsh_condition_translation_input.exit_page_heading_cy).to eq(condition.exit_page_heading_cy)
    end
  end

  describe "#condition_has_answer_value?" do
    context "when the condition has an answer_value" do
      let(:condition) do
        create_condition(answer_value: "Yes")
      end

      it "returns true" do
        expect(welsh_condition_translation_input.condition_has_answer_value?).to be true
      end
    end

    context "when the condition has no answer_value" do
      let(:condition) do
        create_condition(answer_value: nil)
      end

      it "returns false" do
        expect(welsh_condition_translation_input.condition_has_answer_value?).to be false
      end
    end
  end

  describe "#has_translatable_content?" do
    context "when the condition has an answer_value and an exit page" do
      let(:condition) do
        create_condition(answer_value: "Yes",
                         exit_page_heading: "You are ineligible",
                         exit_page_markdown: "Sorry, you are ineligible for this service.")
      end

      it "returns true" do
        expect(welsh_condition_translation_input.has_translatable_content?).to be true
      end
    end

    context "when the condition has an answer_value and no exit page" do
      let(:condition) do
        create_condition(exit_page_heading: nil,
                         exit_page_markdown: nil,
                         answer_value: "Yes")
      end

      it "returns true" do
        expect(welsh_condition_translation_input.has_translatable_content?).to be true
      end
    end

    context "when the condition has an exit page and no answer_value" do
      let(:condition) do
        create_condition(exit_page_heading: "You are ineligible",
                         exit_page_markdown: "Sorry, you are ineligible for this service.",
                         answer_value: nil)
      end

      it "returns true" do
        expect(welsh_condition_translation_input.has_translatable_content?).to be true
      end
    end

    context "when the condition has no exit page or answer_value" do
      let(:condition) do
        create_condition(exit_page_heading: nil,
                         exit_page_markdown: nil,
                         answer_value: nil)
      end

      it "returns true" do
        expect(welsh_condition_translation_input.has_translatable_content?).to be false
      end
    end
  end

  describe "#condition_has_exit_page?" do
    context "when the condition has an exit page" do
      let(:condition) do
        create_condition(exit_page_heading: "You are ineligible",
                         exit_page_markdown: "Sorry, you are ineligible for this service.")
      end

      it "returns true" do
        expect(welsh_condition_translation_input.condition_has_exit_page?).to be true
      end
    end

    context "when the condition has no exit page" do
      let(:condition) do
        create_condition(exit_page_heading: nil,
                         exit_page_markdown: nil)
      end

      it "returns false" do
        expect(welsh_condition_translation_input.condition_has_exit_page?).to be false
      end
    end
  end

  describe "#form_field_id" do
    let(:condition) do
      create_condition(id: 999)
    end

    it "returns the custom ID for each attribute" do
      expect(welsh_condition_translation_input.form_field_id(:answer_value_cy)).to eq "forms_welsh_condition_translation_input_#{condition.id}_condition_translations_answer_value_cy"
      expect(welsh_condition_translation_input.form_field_id(:exit_page_markdown_cy)).to eq "forms_welsh_condition_translation_input_#{condition.id}_condition_translations_exit_page_markdown_cy"
      expect(welsh_condition_translation_input.form_field_id(:exit_page_heading_cy)).to eq "forms_welsh_condition_translation_input_#{condition.id}_condition_translations_exit_page_heading_cy"
    end
  end
end
