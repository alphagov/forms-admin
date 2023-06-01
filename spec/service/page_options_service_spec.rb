require "rails_helper"

describe PageOptionsService do
  subject(:page_options_service) do
    described_class.new(page:, pages:)
  end

  let(:pages) do
    [page, (build :page, id: 2), (build :page, id: 3), (build :page, id: 4)]
  end

  describe "#all_options_for_answer_type" do
    context "with uk and international address" do
      let(:page) { build :page, :with_address_settings, uk_address: "true", international_address: "true", routing_conditions: [] }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") } }],
        )
      end
    end

    context "with international address only" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with uk address" do
      let(:page) { build :page, :with_address_settings, international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") } }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { build :page, :with_date_settings, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.date_settings_options.input_types.date_of_birth") } },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { build :page, :with_date_settings, input_type: "other_date" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.answer_type_options.names.date") } },
        ])
      end
    end

    context "with short text" do
      let(:page) { build :page, :with_text_settings, input_type: "single_line" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.single_line") } },
        ])
      end
    end

    context "with long text" do
      let(:page) { build :page, :with_text_settings, input_type: "long_text" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.long_text") } },
        ])
      end
    end

    context "with selection" do
      let(:page) { build :page, :with_selections_settings }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key:  { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list, one option only." } },
          { key:  { text: I18n.t("selections_settings.options_title") }, value: { text: "<ul class=\"govuk-list\">\n<li>Option 1</li>\n<li>Option 2</li>\n</ul>" } },
        ])
      end
    end

    context "with selection not only_one_option " do
      let(:page) { build :page, :with_selections_settings, only_one_option: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key:  { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list" } },
          { key:  { text: "Options" }, value: { text: "<ul class=\"govuk-list\">\n<li>Option 1</li>\n<li>Option 2</li>\n</ul>" } },
        ])
      end
    end

    context "with full name, no title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "full_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>Full name in a single box</li>\n<li>Title not needed</li>\n</ul>" } },
        ])
      end
    end

    context "with first_and_last_name, title needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>First and last names in separate boxes</li>\n<li>Title needed</li>\n</ul>" } },
        ])
      end
    end

    context "with first_middle_and_last_name, title no needed" do
      let(:page) { build :page, :with_name_settings, input_type: "first_middle_and_last_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\">\n<li>Person’s name</li>\n<li>First, middle and last names in separate boxes</li>\n<li>Title not needed</li>\n</ul>" } },
        ])
      end
    end

    Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.each do |answer_type|
      context "with #{answer_type}" do
        let(:page) { build :page, answer_type: }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to eq([
            { key:  { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") } },
          ])
        end
      end
    end

    context "with basic routing enabled", feature_basic_routing: true do
      let(:page) { build :page, id: 1, answer_type: "email", routing_conditions: }
      let(:condition_1) { build :condition, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }
      let(:condition_2) { build :condition, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 4 }
      let(:routing_conditions) { nil }

      context "with a legacy page that doesn't have routing conditions method" do
        subject(:page_options_service) do
          page_without_routing_conditions_method = page.dup.tap { |p| p.routing_conditions = nil }
          described_class.new(page: page_without_routing_conditions_method, pages:)
        end

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            { key:  { text: "Answer type" }, value: { text: "Email address" } },
          )
        end
      end

      context "with no condition" do
        let(:routing_conditions) { [] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            { key:  { text: "Answer type" }, value: { text: "Email address" } },
          )
        end
      end

      context "with a single condition" do
        let(:routing_conditions) { [condition_1] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html", answer_value: condition_1.answer_value, goto_page_number: 3, goto_page_text: pages[2].question_text) },
            },
          )
        end
      end

      context "with multiple conditions" do
        let(:routing_conditions) { [condition_1, condition_2] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: "<ol class=\"govuk-list govuk-list--number\"><li>#{I18n.t('page_conditions.condition_compact_html', answer_value: condition_1.answer_value, goto_page_number: 3, goto_page_text: pages[2].question_text)}</li><li>#{I18n.t('page_conditions.condition_compact_html', answer_value: condition_2.answer_value, goto_page_number: 4, goto_page_text: pages[3].question_text)}</li></ol>" },
            },
          )
        end
      end

      context "with a condition that points to the end of the form" do
        let(:routing_conditions) { [condition] }
        let(:answer_value) { "Wales" }
        let(:condition) { build :condition, answer_value:, goto_page_id: nil, skip_to_end: true }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_end_of_form", answer_value:) },
            },
          )
        end
      end
    end
  end
end
