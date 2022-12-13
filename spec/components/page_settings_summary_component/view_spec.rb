require "rails_helper"

RSpec.describe PageSettingsSummaryComponent::View, type: :component do
  let(:page_object) { build :page, :without_selection_answer_type, id: 1 }
  let(:change_answer_type_path) { "https://example.com/change_answer_type" }
  let(:change_selections_settings_path) { "https://example.com/change_selections_settings" }

  context "when the page is not a selection page" do
    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path))
      expect(page).to have_link("Change Answer type", href: change_answer_type_path)
    end

    it "does not have links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path, change_selections_settings_path))
      expect(page).not_to have_link("Change Options", href: change_selections_settings_path)
      expect(page).not_to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).not_to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "does not render the selection settings" do
      render_inline(described_class.new(page_object, change_answer_type_path, change_selections_settings_path))
      expect(page).not_to have_text "Selection from a list"
      expect(page).not_to have_text "Option 1, Option 2"
    end
  end

  context "when the page is a selection page" do
    let(:page_object) do
      page = FactoryBot.build(:page, :with_selections_settings, id: 1)
      page.answer_settings = OpenStruct.new(page.answer_settings)
      page
    end

    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path, change_selections_settings_path))
      expect(page).to have_link("Change Answer type Selection from a list", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path, change_selections_settings_path))
      expect(page).to have_link("Change Options", href: change_selections_settings_path)
      expect(page).to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "renders the selection settings" do
      render_inline(described_class.new(page_object, change_answer_type_path, change_selections_settings_path))
      expect(page).to have_text "Selection from a list"
      expect(page).to have_text "Option 1, Option 2"
      expect(page).to have_text "Yes"
      expect(page).to have_text "No"
    end
  end
end
