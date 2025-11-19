require "rails_helper"

RSpec.describe Forms::WelshConditionTranslationInput, type: :model do
  subject(:welsh_condition_translation_input) { described_class.new(new_input_data) }

  let(:condition) { create_condition }
  let(:page) { create :page }

  let(:new_input_data) do
    {
      id: condition.id,
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
      exit_page_markdown_cy: "",
      exit_page_heading_cy: "",
    }
    create(:condition, default_attributes.merge(attributes))
  end

  describe "#submit" do
    it "returns true" do
      expect(welsh_condition_translation_input.submit).to be true
    end

    it "updates the condition's welsh attributes with the new values" do
      welsh_condition_translation_input.submit
      condition.reload

      expect(condition.reload.exit_page_markdown_cy).to eq(new_input_data[:exit_page_markdown_cy])
      expect(condition.reload.exit_page_heading_cy).to eq(new_input_data[:exit_page_heading_cy])
    end

    it "does not update any non-welsh attributes" do
      english_value_before = condition.answer_value
      welsh_condition_translation_input.submit
      expect(condition.reload.answer_value).to eq(english_value_before)
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
      expect(welsh_condition_translation_input.form_field_id(:exit_page_markdown_cy)).to eq "forms_welsh_condition_translation_input_#{condition.id}_condition_translations_exit_page_markdown_cy"
      expect(welsh_condition_translation_input.form_field_id(:exit_page_heading_cy)).to eq "forms_welsh_condition_translation_input_#{condition.id}_condition_translations_exit_page_heading_cy"
    end
  end
end
