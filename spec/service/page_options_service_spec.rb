require "rails_helper"

describe PageOptionsService do
  subject(:page_options_service) do
    described_class.new(page:)
  end

  describe "#all_options_for_answer_type" do
    context "with uk and international address" do
      let(:page) { build :page, :with_address_settings, uk_address: "true", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") }],
        )
      end
    end

    context "with international address only" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") }],
        )
      end
    end

    context "with uk address" do
      let(:page) { build :page, :with_address_settings, international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { build :page, :with_date_settings, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.date_settings_options.input_types.date_of_birth") },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { build :page, :with_date_settings, input_type: "other_date" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.date") },
        ])
      end
    end

    context "with short text" do
      let(:page) { build :page, :with_text_settings, input_type: "single_line" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.text_settings_options.names.single_line") },
        ])
      end
    end

    context "with long text" do
      let(:page) { build :page, :with_text_settings, input_type: "long_text" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.text_settings_options.names.long_text") },
        ])
      end
    end

    context "with selection" do
      let(:page) { build :page, :with_selections_settings }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: "Selection from a list, one option only." },
          { key: I18n.t("selections_settings.options_title"), value: "<ul class=\"govuk-list\">\n<li>Option 1</li>\n<li>Option 2</li>\n</ul>" },
        ])
      end
    end

    context "with selection not only_one_option " do
      let(:page) { build :page, :with_selections_settings, only_one_option: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: "Selection from a list" },
          { key: "Options", value: "<ul class=\"govuk-list\">\n<li>Option 1</li>\n<li>Option 2</li>\n</ul>" },
        ])
      end
    end

    context "with full name, no title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "full_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>Full name in a single field</li>\n<li>Title not needed</li>\n</ul>" },
        ])
      end
    end

    context "with first_and_last_name, title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>First and last names in separate fields</li>\n<li>Title needed</li>\n</ul>" },
        ])
      end
    end

    context "with first_middle_and_last_name, title no needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_middle_and_last_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>First, middle and last names in separate fields</li>\n<li>Title not needed</li>\n</ul>" },
        ])
      end
    end

    Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.each do |answer_type|
      context "with #{answer_type}" do
        let(:page) { build :page, answer_type: }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to eq([
            { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") },
          ])
        end
      end
    end
  end
end
