require "rails_helper"

RSpec.describe PageSettingsSummaryComponent::View, type: :component do
  let(:draft_question) { build :draft_question }
  let(:change_answer_type_path) { "https://example.com/change_answer_type" }
  let(:change_selections_settings_path) { "https://example.com/change_selections_settings" }
  let(:change_text_settings_path) { "https://example.com/change_text_settings" }
  let(:change_date_settings_path) { "https://example.com/change_date_settings" }
  let(:change_address_settings_path) { "https://example.com/change_address_settings" }
  let(:change_name_settings_path) { "https://example.com/change_name_settings" }

  context "when the page is not a selection page" do
    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:))
      expect(page).to have_link("Change Answer type", href: change_answer_type_path)
    end

    it "does not have links to change the selection options" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
      expect(page).not_to have_link("Change Options", href: change_selections_settings_path)
      expect(page).not_to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).not_to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "does not render the selection settings" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
      expect(page).not_to have_text "Selection from a list"
      expect(page).not_to have_text "Option 1, Option 2"
    end
  end

  context "when the draft question is a 'select from a list'" do
    let(:draft_question) { build :selection_draft_question }

    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
      expect(page).to have_link("Change Answer type Selection from a list", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
      expect(page).to have_link("Change Options", href: change_selections_settings_path)
      expect(page).to have_link("Change People can only select one option", href: change_selections_settings_path)
      expect(page).to have_link("Change Include an option for ‘None of the above’", href: change_selections_settings_path)
    end

    it "renders the selection settings" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
      rows = page.find_all(".govuk-summary-list__row")

      expect(rows[0].find(".govuk-summary-list__key")).to have_text "Answer type"
      expect(rows[0].find(".govuk-summary-list__value")).to have_text "Selection from a list"
      expect(rows[1].find(".govuk-summary-list__key")).to have_text "Options"
      expect(rows[1].find(".govuk-summary-list__value")).to have_text "Option 1, Option 2"
      expect(rows[2].find(".govuk-summary-list__key")).to have_text "People can only select one option"
      expect(rows[2].find(".govuk-summary-list__value")).to have_text "Yes"
      expect(rows[3].find(".govuk-summary-list__key")).to have_text "Include an option for ‘None of the above’"
      expect(rows[3].find(".govuk-summary-list__value")).to have_text "No"
    end

    context "when 'None of the above' is a setting" do
      let(:draft_question) { build :selection_draft_question, is_optional: true }

      it "renders the selection settings" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
        rows = page.find_all(".govuk-summary-list__row")

        expect(rows[0].find(".govuk-summary-list__key")).to have_text "Answer type"
        expect(rows[0].find(".govuk-summary-list__value")).to have_text "Selection from a list"
        expect(rows[1].find(".govuk-summary-list__key")).to have_text "Options"
        expect(rows[1].find(".govuk-summary-list__value")).to have_text "Option 1, Option 2"
        expect(rows[2].find(".govuk-summary-list__key")).to have_text "People can only select one option"
        expect(rows[2].find(".govuk-summary-list__value")).to have_text "Yes"
        expect(rows[3].find(".govuk-summary-list__key")).to have_text "Include an option for ‘None of the above’"
        expect(rows[3].find(".govuk-summary-list__value")).to have_text "Yes"
      end
    end
  end

  context "when the page is a text page" do
    let(:draft_question) { build :text_draft_question, input_type: }
    let(:input_type) { "single_line" }

    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_link("Change Answer type Text", href: change_answer_type_path)
    end

    it "has links to change the selection options" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_link("Change input type", href: change_text_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_text_settings_path:))
      expect(page).to have_text "Length"
      expect(page).to have_text I18n.t("helpers.label.page.text_settings_options.names.#{draft_question.answer_settings.with_indifferent_access[:input_type]}")
    end

    context "when input_type is long text" do
      let(:input_type) { "long_text" }

      it "has links to change the selection options" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_text_settings_path:))
        expect(page).to have_link("Change input type", href: change_text_settings_path)
      end

      it "renders the input type" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_text_settings_path:))
        expect(page).to have_text "Length"
        expect(page).to have_text I18n.t("helpers.label.page.text_settings_options.names.#{draft_question.answer_settings.with_indifferent_access[:input_type]}")
      end
    end
  end

  context "when the page is a date page" do
    let(:draft_question) { build :date_draft_question }

    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_link("Change Answer type Date", href: change_answer_type_path)
    end

    it "has a link to change the input type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_link("Change input type", href: change_date_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_date_settings_path:))
      expect(page).to have_text "Date of birth"
      expect(page).to have_text I18n.t("helpers.label.page.date_settings_options.input_types.#{draft_question.answer_settings.with_indifferent_access[:input_type]}")
    end

    context "when the date has no answer settings" do
      let(:draft_question) { build :date_draft_question, answer_settings: nil }

      it "has no link to change the input type" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_date_settings_path:))
        expect(page).not_to have_link("Change input type", href: change_date_settings_path)
      end
    end
  end

  context "when the page is an address page" do
    let(:draft_question) { build :address_draft_question, uk_address:, international_address: }
    let(:uk_address) { "true" }
    let(:international_address) { "true" }

    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_link("Change Answer type Address", href: change_answer_type_path)
    end

    it "has links to change the answer settings" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_link("Change input type", href: change_address_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_address_settings_path:))
      expect(page).to have_text "Address type"
      expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses")
    end

    context "when the input type is uk addresses only" do
      let(:uk_address) { "true" }
      let(:international_address) { "false" }

      it "renders the input type as uk addresses" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_address_settings_path:))
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_addresses")
      end
    end

    context "when the input type is international addresses only" do
      let(:uk_address) { "false" }
      let(:international_address) { "true" }

      it "renders the input type as international addresses" do
        render_inline(described_class.new(draft_question, change_answer_type_path:, change_address_settings_path:))
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.international_addresses")
      end
    end
  end

  context "when the page is a name page" do
    let(:draft_question) { build :name_draft_question, input_type:, title_needed: }
    let(:input_type) { "full_name" }
    let(:title_needed) { "true" }

    it "has a link to change the answer type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_name_settings_path:))
      expect(page).to have_link("Change Answer type Person’s name", href: change_answer_type_path)
    end

    it "has links to change the answer settings" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_name_settings_path:))
      expect(page).to have_link("Change input type", href: change_name_settings_path)
      expect(page).to have_link("Change title needed", href: change_name_settings_path)
    end

    it "renders the input type" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_name_settings_path:))
      expect(page).to have_text "Name fields"
      expect(page).to have_text I18n.t("helpers.label.page.name_settings_options.names.full_name")
    end

    it "renders the title needed" do
      render_inline(described_class.new(draft_question, change_answer_type_path:, change_name_settings_path:))
      expect(page).to have_text "Title needed"
      expect(page).to have_text I18n.t("helpers.label.page.name_settings_options.names.true")
    end
  end
end
