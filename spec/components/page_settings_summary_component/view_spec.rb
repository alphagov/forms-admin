require "rails_helper"

RSpec.describe PageSettingsSummaryComponent::View, type: :component do
  let(:page_object) { build :page, :with_simple_answer_type, id: 1 }
  let(:change_answer_type_path) { "https://example.com/change_answer_type" }
  let(:change_selections_settings_path) { "https://example.com/change_selections_settings" }
  let(:change_text_settings_path) { "https://example.com/change_text_settings" }
  let(:change_date_settings_path) { "https://example.com/change_date_settings" }
  let(:change_address_settings_path) { "https://example.com/change_address_settings" }

  context "when the page is not a selection page" do
    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path:))
      expect(page).to have_link("Change Answer type", href: change_answer_type_path)
    end

    it "does not have links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_selections_settings_path:))
      expect(page).not_to have_link("Change Options", href: change_selections_settings_path)
      expect(page).not_to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).not_to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "does not render the selection settings" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_selections_settings_path:))
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
      render_inline(described_class.new(page_object, change_answer_type_path:, change_selections_settings_path:))
      expect(page).to have_link("Change Answer type Selection from a list", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_selections_settings_path:))
      expect(page).to have_link("Change Options", href: change_selections_settings_path)
      expect(page).to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "renders the selection settings" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_selections_settings_path:))
      expect(page).to have_text "Selection from a list"
      expect(page).to have_text "Option 1, Option 2"
      expect(page).to have_text "Yes"
      expect(page).to have_text "No"
    end
  end

  context "when the page is a text page" do
    let(:page_object) do
      page = FactoryBot.build(:page, :with_text_settings, id: 1)
      page.answer_settings = OpenStruct.new(page.answer_settings)
      page
    end

    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_link("Change Answer type Text", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_link("Change input type", href: change_text_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_text "Input type"
      expect(page).to have_text I18n.t("helpers.label.page.text_settings_options.names.#{page_object.answer_settings.input_type}")
    end
  end

  context "when the page is a date page" do
    let(:page_object) do
      page = FactoryBot.build(:page, :with_date_settings, id: 1)
      page.answer_settings = OpenStruct.new(page.answer_settings)
      page
    end

    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_link("Change Answer type Date", href: change_answer_type_path)
    end

    it "has a link to change the input type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_link("Change input type", href: change_date_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_text "Input type"
      expect(page).to have_text I18n.t("helpers.label.page.date_settings_options.input_types.#{page_object.answer_settings.input_type}")
    end

    context "when the date has no answer settings" do
      let(:page_object) do
        page = FactoryBot.build(:page, :with_date_settings, id: 1)
        page.answer_settings = nil
        page
      end

      it "has no link to change the input type" do
        render_inline(described_class.new(page_object, change_answer_type_path:, change_date_settings_path:))
        expect(page).not_to have_link("Change input type", href: change_date_settings_path)
      end
    end
  end

  context "when the page is an address page" do
    let(:page_object) do
      page = FactoryBot.build(:page, :with_address_settings, id: 1)
      page.answer_settings = OpenStruct.new(page.answer_settings)
      page.answer_settings.input_type = input_type
      page
    end

    let(:input_type) { OpenStruct.new({ uk_address:, international_address: }) }
    let(:uk_address) { "true" }
    let(:international_address) { "true" }

    it "has a link to change the answer type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_link("Change Answer type Address", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_link("Change input type", href: change_address_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(page_object, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_text "Input type"
      expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses")
    end

    context "when the input type is uk addresses only" do
      let(:uk_address) { "true" }
      let(:international_address) { "false" }

      it "renders the input type as uk addresses" do
        render_inline(described_class.new(page_object, change_answer_type_path:, change_address_settings_path:))
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_addresses")
      end
    end

    context "when the input type is international addresses only" do
      let(:uk_address) { "false" }
      let(:international_address) { "true" }

      it "renders the input type as international addresses" do
        render_inline(described_class.new(page_object, change_answer_type_path:, change_address_settings_path:))
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.international_addresses")
      end
    end
  end
end
