require "rails_helper"

describe PageOptionsService do
  subject(:page_options_service) do
    described_class.new(page:)
  end

  describe "#all_options_for_answer_type" do
    context "with uk and interational address" do
      let(:page) { build :page, :with_address_settings, uk_address: "true", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.address") },
           { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
           { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") }],
        )
      end
    end

    context "with interational address only" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.address") },
           { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
           { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") }],
        )
      end
    end

    context "with uk address" do
      let(:page) { build :page, :with_address_settings, international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.address") },
           { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
           { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.address") },
           { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
           { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { build :page, :with_date_settings, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.date") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.date_settings_options.input_types.date_of_birth") },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { build :page, :with_date_settings, input_type: "other_date" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.date") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.date_settings_options.input_types.other_date") },
        ])
      end
    end

    context "with short text" do
      let(:page) { build :page, :with_text_settings, input_type: "single_line" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.text") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.text_settings_options.names.single_line") },
        ])
      end
    end

    context "with long text" do
      let(:page) { build :page, :with_text_settings, input_type: "long_text" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.text") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.text_settings_options.names.long_text") },
        ])
      end
    end

    context "with selection" do
      let(:page) { build :page, :with_selections_settings }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.#{page.answer_type}") },
          { key: I18n.t("selections_settings.options_title"), value: "Option 1, Option 2" },
          { key: I18n.t("selections_settings.only_one_option"), value: I18n.t("selections_settings.yes") },
          { key: I18n.t("selections_settings.include_none_of_the_above"), value: I18n.t("selections_settings.no") },
        ])
      end
    end

    context "with selection not only_one_option " do
      let(:page) { build :page, :with_selections_settings, only_one_option: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.#{page.answer_type}") },
          { key: I18n.t("selections_settings.options_title"), value: "Option 1, Option 2" },
          { key: I18n.t("selections_settings.only_one_option"), value: I18n.t("selections_settings.no") },
          { key: I18n.t("selections_settings.include_none_of_the_above"), value: I18n.t("selections_settings.no") },
        ])
      end
    end

    context "with full name, no title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "full_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.name") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.name_settings_options.names.full_name") },
          { key: I18n.t("helpers.label.page.name_settings_options.title_needed.name"), value: I18n.t("helpers.label.page.name_settings_options.title_needed.false") },
        ])
      end
    end

    context "with first_and_last_name, title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.name") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.name_settings_options.names.first_and_last_name") },
          { key: I18n.t("helpers.label.page.name_settings_options.title_needed.name"), value: I18n.t("helpers.label.page.name_settings_options.title_needed.true") },
        ])
      end
    end

    context "with first_middle_and_last_name, title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_middle_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.name") },
          { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          { key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.name_settings_options.names.first_middle_and_last_name") },
          { key: I18n.t("helpers.label.page.name_settings_options.title_needed.name"), value: I18n.t("helpers.label.page.name_settings_options.title_needed.true") },
        ])
      end
    end

    %w[number national_insurance_number email phone_number single_line organisation_name long_text].each do |answer_type|
      context "with #{answer_type}" do
        let(:page) { build :page, answer_type: }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to eq([
            { key: I18n.t("helpers.label.page.answer_type_options.title"), value: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") },
            { key: I18n.t("helpers.label.page.answer_type_options.optional"), value: I18n.t("helpers.label.page.answer_type_options.optional_no") },
          ])
        end
      end
    end
  end
end
