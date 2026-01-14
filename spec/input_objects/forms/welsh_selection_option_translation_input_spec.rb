require "rails_helper"

RSpec.describe Forms::WelshSelectionOptionTranslationInput, type: :model do
  subject(:welsh_selection_option_translation_input) { described_class.new(new_input_data) }

  let(:page) { build :page, :with_selection_settings, id: 747 }
  let(:selection_option_cy) { DataStruct.new(name: "Option 1", value: page.answer_settings.selection_options.first["value"]) }

  let(:new_input_data) do
    {
      selection_option: selection_option_cy,
      page:,
      id: "1",
      name_cy: "Other name",
    }
  end

  describe "id" do
    it "converts the id to an integer" do
      expect(welsh_selection_option_translation_input.id).to eq(1)
    end
  end

  describe "#assign_selection_option_values" do
    it "assigns the selection option name" do
      welsh_selection_option_translation_input.assign_selection_option_values
      expect(welsh_selection_option_translation_input.name_cy).to eq(selection_option_cy["name"])
    end

    it "does not assign the selection option name if the selection option is nil" do
      welsh_selection_option_translation_input.selection_option = nil
      welsh_selection_option_translation_input.assign_selection_option_values
      expect(welsh_selection_option_translation_input.name_cy).to eq("Other name")
    end
  end

  describe "#as_selection_option" do
    it "returns a hash with the selection option name and value" do
      welsh_selection_option_translation_input.assign_selection_option_values
      expect(welsh_selection_option_translation_input.as_selection_option).to eq(name: selection_option_cy["name"], value: selection_option_cy["value"])
    end
  end

  describe "#form_field_id" do
    it "returns the custom ID for each attribute" do
      expect(welsh_selection_option_translation_input.form_field_id(:name_cy)).to eq "forms_welsh_selection_option_translation_input_747_selection_options_cy_1_name_cy"
    end
  end

  describe "#selection_number" do
    it "returns the id add one" do
      expect(welsh_selection_option_translation_input.selection_number).to eq(2)
    end
  end

  describe "#question_number" do
    it "returns the page position" do
      expect(welsh_selection_option_translation_input.question_number).to eq(page.position)
    end
  end
end
