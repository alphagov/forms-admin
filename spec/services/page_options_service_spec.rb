require "rails_helper"

describe PageOptionsService do
  subject(:page_options_service) do
    described_class.new(page:, pages:)
  end

  let(:pages) do
    [page, (build :made_live_page, id: 2), (build :made_live_page, id: 3), (build :made_live_page, id: 4)]
  end

  describe "#all_options_for_answer_type" do
    context "with uk and international address" do
      let(:page) { build :made_live_page, :with_address_settings, uk_address: "true", international_address: "true", routing_conditions: [] }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") } }],
        )
      end
    end

    context "with international address only" do
      let(:page) { build :made_live_page, :with_address_settings, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with uk address" do
      let(:page) { build :made_live_page, :with_address_settings, international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") } }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { build :made_live_page, :with_address_settings, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { build :made_live_page, :with_date_settings, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "Date of birth" } },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { build :made_live_page, :with_date_settings, input_type: "other_date" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "Date" } },
        ])
      end
    end

    context "with short text" do
      let(:page) { build :made_live_page, :with_text_settings, input_type: "single_line" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.single_line") } },
        ])
      end
    end

    context "with long text" do
      let(:page) { build :made_live_page, :with_text_settings, input_type: "long_text" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.long_text") } },
        ])
      end
    end

    context "with selection" do
      let(:page) do
        build :made_live_page,
              is_optional: "false",
              answer_type: "selection",
              answer_settings: OpenStruct.new(only_one_option: "true",
                                              selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                                                                  OpenStruct.new(attributes: { name: "Option 2" })])
      end

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list, one option only" } },
          { key: { text: I18n.t("page_options_service.options_title") }, value: { text: "<p class=\"govuk-body-s\">2 options:</p><ul class=\"govuk-list govuk-list--bullet\"><li>Option 1</li><li>Option 2</li></ul>" } },
        ])
      end
    end

    context "with selection not only_one_option" do
      let(:page) do
        build :made_live_page,
              is_optional: "false",
              answer_type: "selection",
              answer_settings: OpenStruct.new(only_one_option: "false",
                                              selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                                                                  OpenStruct.new(attributes: { name: "Option 2" })])
      end

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list" } },
          { key: { text: "Options" }, value: { text: "<p class=\"govuk-body-s\">2 options:</p><ul class=\"govuk-list govuk-list--bullet\"><li>Option 1</li><li>Option 2</li></ul>" } },
        ])
      end
    end

    context "with selection with more than ten options" do
      let(:option_names) { Array.new(11).each_with_index.map { |_element, index| "Option #{index}" } }
      let(:selection_options) { option_names.map { |option| OpenStruct.new(attributes: { name: option }) } }
      let(:page) do
        build :made_live_page,
              is_optional: "false",
              answer_type: "selection",
              answer_settings: OpenStruct.new(only_one_option: "false", selection_options:)
      end

      it "returns the options in a details component" do
        expected_list_items = "<li>#{option_names.join('</li><li>')}</li>"

        expected_options_html = "<details class=\"govuk-details\"><summary class=\"govuk-details__summary\">" \
          "<span class=\"govuk-details__summary-text\">Show 11 options</span></summary>" \
          "<div class=\"govuk-details__text\"><ul class=\"govuk-list govuk-list--bullet\">" \
          "#{expected_list_items}" \
          "</ul></div></details>"

        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list" } },
          { key: { text: "Options" }, value: { text: expected_options_html } },
        ])
      end
    end

    context "with full name, no title needed" do
      let(:page) { build :made_live_page, :with_name_settings, input_type: "full_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>Full name in a single box</li><li>Title not needed</li></ul>" } },
        ])
      end
    end

    context "with first_and_last_name, title needed" do
      let(:page) { build :made_live_page, :with_name_settings, input_type: "first_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>First and last names in separate boxes</li><li>Title needed</li></ul>" } },
        ])
      end
    end

    context "with first_middle_and_last_name, title no needed" do
      let(:page) { build :made_live_page, :with_name_settings, input_type: "first_middle_and_last_name", title_needed: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>First, middle and last names in separate boxes</li><li>Title not needed</li></ul>" } },
        ])
      end
    end

    Page::ANSWER_TYPES_WITHOUT_SETTINGS.each do |answer_type|
      context "with #{answer_type}" do
        let(:page) { build :made_live_page, answer_type: }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to eq([
            { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") } },
          ])
        end
      end
    end

    context "with conditions" do
      let(:page) { build :made_live_page, id: 1, answer_type: "email", routing_conditions: }
      let(:condition_pointing_to_page_3) { build :made_live_condition, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 } # rubocop:disable RSpec/IndexedLet
      let(:condition_pointing_to_page_4) { build :made_live_condition, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 4 } # rubocop:disable RSpec/IndexedLet
      let(:routing_conditions) { nil }

      context "with a legacy page that doesn't have routing conditions method" do
        subject(:page_options_service) do
          page_without_routing_conditions_method = page.dup.tap { |p| p.routing_conditions = nil }
          described_class.new(page: page_without_routing_conditions_method, pages:)
        end

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            { key: { text: "Answer type" }, value: { text: "Email address" } },
          )
        end
      end

      context "with no condition" do
        let(:routing_conditions) { [] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            { key: { text: "Answer type" }, value: { text: "Email address" } },
          )
        end
      end

      context "with a single condition" do
        let(:routing_conditions) { [condition_pointing_to_page_3] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html", answer_value: condition_pointing_to_page_3.answer_value, goto_page_question_number: 3, goto_page_question_text: pages[2].question_text) },
            },
          )
        end
      end

      context "with multiple conditions" do
        let(:routing_conditions) { [condition_pointing_to_page_3, condition_pointing_to_page_4] }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: "<ol class=\"govuk-list govuk-list--number\"><li>#{I18n.t('page_conditions.condition_compact_html', answer_value: condition_pointing_to_page_3.answer_value, goto_page_question_number: 3, goto_page_question_text: pages[2].question_text)}</li><li>#{I18n.t('page_conditions.condition_compact_html', answer_value: condition_pointing_to_page_4.answer_value, goto_page_question_number: 4, goto_page_question_text: pages[3].question_text)}</li></ol>" },
            },
          )
        end
      end

      context "with a condition that points to the end of the form" do
        let(:routing_conditions) { [condition] }
        let(:answer_value) { "Wales" }
        let(:condition) { build :made_live_condition, answer_value:, goto_page_id: nil, skip_to_end: true }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_end_of_form", answer_value:) },
            },
          )
        end
      end

      context "with a secondary skip" do
        let(:page) { build :made_live_page, routing_conditions: }
        let(:skip_condition) { build :made_live_condition, routing_page_id: pages.third.id, goto_page_id: pages.fourth.id, check_page_id: page.id, skip_to_end: false }

        it "returns the correct options" do
          page.routing_conditions = [skip_condition]
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_secondary_skip", goto_page_question_number: 4, goto_page_question_text: pages.fourth.question_text) },
            },
          )
        end
      end

      context "with an exit page" do
        let(:page) { build :made_live_page, routing_conditions: }
        let(:exit_page_condition) { build :made_live_condition, routing_page_id: page.id, answer_value: "yes", goto_page_id: nil, check_page_id: page.id, exit_page_markdown: "Exit!", exit_page_heading: "You are not eligible" }

        it "returns the correct options" do
          page.routing_conditions = [exit_page_condition]
          expect(page_options_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_exit_page", answer_value: "yes", exit_page_heading: "You are not eligible") },
            },
          )
        end
      end
    end

    context "with guidance" do
      let(:page) { build :made_live_page, :with_guidance }

      it "returns the correct page heading" do
        expect(page_options_service.all_options_for_answer_type).to include(
          { key: { text: I18n.t("page_options_service.page_heading") },
            value: { text: page.page_heading } },
        )
      end

      it "returns the correct guidance markdown" do
        expect(page_options_service.all_options_for_answer_type).to include(
          { key: { text: I18n.t("page_options_service.guidance_markdown") },
            value: { text: "<pre class=\"app-markdown-editor__markdown-example-block\">#{page.guidance_markdown}</pre>" } },
        )
      end

      context "when page doesn't have a page_heading or guidance_markdown method defined" do
        let(:page) do
          build(:page).tap do |p|
            p.attributes.delete(:page_heading)
            p.attributes.delete(:guidance_markdown)
          end
        end

        it "does not raise an error" do
          expect { page_options_service.all_options_for_answer_type }.not_to raise_error
        end

        it "does not return a page heading key" do
          expect(page_options_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("page_options_service.page_heading") } },
          )
        end

        it "does not return a guidance markdown key" do
          expect(page_options_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("page_options_service.guidance_markdown") } },
          )
        end
      end
    end

    context "with answer type of file" do
      context "when file upload question does not have a page heading" do
        let(:page) { build :made_live_page, :with_file_upload_answer_type }

        it "does not include the question text" do
          expect(page_options_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("reports.form_or_questions_list_table.headings.question_text") },
              value: { text: page.question_text } },
          )
        end
      end

      context "when file upload question contains guidance text" do
        let(:page) { build :made_live_page, :with_guidance, :with_file_upload_answer_type }

        it "returns question text" do
          expect(page_options_service.all_options_for_answer_type).to include(
            { key: { text: I18n.t("reports.form_or_questions_list_table.headings.question_text") },
              value: { text: page.question_text } },
          )
        end

        it "does not return page heading" do
          expect(page_options_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("page_options_service.page_heading") } },
          )
        end
      end
    end
  end
end
