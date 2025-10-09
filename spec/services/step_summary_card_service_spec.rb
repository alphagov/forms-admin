require "rails_helper"

describe StepSummaryCardService do
  subject(:step_summary_card_service) do
    described_class.new(step: form_document_step, steps: form_document_steps)
  end

  let(:form_document_content) { FormDocument::Content.from_form_document(form.live_form_document) }
  let(:form_document_steps) { form_document_content.steps }
  let(:form_document_step) { FormDocument::Step.new(page.as_form_document_step(nil)) }

  let(:form) { create :form, :live }

  let(:pages) { form.pages }

  describe "#all_options_for_answer_type" do
    context "with uk and international address" do
      let(:page) { create :page, :with_address_settings, form:, uk_address: "true", international_address: "true" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") } }],
        )
      end
    end

    context "with international address only" do
      let(:page) { create :page, :with_address_settings, form:, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with uk address" do
      let(:page) { create :page, :with_address_settings, form:, international_address: "false" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") } }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { create :page, :with_address_settings, form:, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq(
          [{ key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
             value: { text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") } }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { create :page, :with_date_settings, form:, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "Date of birth" } },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { create :page, :with_date_settings, form:, input_type: "other_date" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "Date" } },
        ])
      end
    end

    context "with short text" do
      let(:page) { create :page, :with_text_settings, form:, input_type: "single_line" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.single_line") } },
        ])
      end
    end

    context "with long text" do
      let(:page) { create :page, :with_text_settings, form:, input_type: "long_text" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: I18n.t("helpers.label.page.text_settings_options.names.long_text") } },
        ])
      end
    end

    context "with selection" do
      let(:page) do
        create :page,
               form:,
               is_optional: "false",
               answer_type: "selection",
               answer_settings: DataStruct.new(only_one_option: "true",
                                               selection_options: [DataStruct.new({ name: "Option 1" }),
                                                                   DataStruct.new({ name: "Option 2" })])
      end

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list, one option only" } },
          { key: { text: I18n.t("step_summary_card.options_title") }, value: { text: "<p class=\"govuk-body-s\">2 options:</p><ul class=\"govuk-list govuk-list--bullet\"><li>Option 1</li><li>Option 2</li></ul>" } },
        ])
      end
    end

    context "with selection not only_one_option" do
      let(:page) do
        create :page,
               form:,
               is_optional: "false",
               answer_type: "selection",
               answer_settings: DataStruct.new(only_one_option: "false",
                                               selection_options: [DataStruct.new({ name: "Option 1" }),
                                                                   DataStruct.new({ name: "Option 2" })])
      end

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list" } },
          { key: { text: "Options" }, value: { text: "<p class=\"govuk-body-s\">2 options:</p><ul class=\"govuk-list govuk-list--bullet\"><li>Option 1</li><li>Option 2</li></ul>" } },
        ])
      end
    end

    context "with selection with more than ten options" do
      let(:option_names) { Array.new(11).each_with_index.map { |_element, index| "Option #{index}" } }
      let(:selection_options) { option_names.map { |option| DataStruct.new({ name: option }) } }
      let(:page) do
        create :page,
               form:,
               is_optional: "false",
               answer_type: "selection",
               answer_settings: DataStruct.new(only_one_option: "false", selection_options:)
      end

      it "returns the options in a details component" do
        expected_list_items = "<li>#{option_names.join('</li><li>')}</li>"

        expected_options_html = "<details class=\"govuk-details\"><summary class=\"govuk-details__summary\">" \
          "<span class=\"govuk-details__summary-text\">Show 11 options</span></summary>" \
          "<div class=\"govuk-details__text\"><ul class=\"govuk-list govuk-list--bullet\">" \
          "#{expected_list_items}" \
          "</ul></div></details>"

        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: "Selection from a list" } },
          { key: { text: "Options" }, value: { text: expected_options_html } },
        ])
      end
    end

    context "with full name, no title needed" do
      let(:page) { create :page, :with_name_settings, form:, input_type: "full_name", title_needed: "false" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>Full name in a single box</li><li>Title not needed</li></ul>" } },
        ])
      end
    end

    context "with first_and_last_name, title needed" do
      let(:page) { create :page, :with_name_settings, form:, input_type: "first_and_last_name", title_needed: "true" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>First and last names in separate boxes</li><li>Title needed</li></ul>" } },
        ])
      end
    end

    context "with first_middle_and_last_name, title no needed" do
      let(:page) { create :page, :with_name_settings, form:, input_type: "first_middle_and_last_name", title_needed: "false" }

      it "returns the correct options" do
        expect(step_summary_card_service.all_options_for_answer_type).to eq([
          { key: { text: I18n.t("helpers.label.page.answer_type_options.title") },
            value: { text: "<ul class=\"govuk-list\"><li>Person’s name</li><li>First, middle and last names in separate boxes</li><li>Title not needed</li></ul>" } },
        ])
      end
    end

    Page::ANSWER_TYPES_WITHOUT_SETTINGS.each do |answer_type|
      context "with #{answer_type}" do
        let(:page) { create :page, form:, answer_type: }

        it "returns the correct options" do
          expect(step_summary_card_service.all_options_for_answer_type).to eq([
            { key: { text: I18n.t("helpers.label.page.answer_type_options.title") }, value: { text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") } },
          ])
        end
      end
    end

    context "with no condition" do
      let(:page) { create :page, form:, answer_type: "email" }

      it "does not include a route" do
        expect(step_summary_card_service.all_options_for_answer_type).not_to include(
          { key: { text: I18n.t("page_conditions.route") } },
        )
      end
    end

    context "with conditions" do
      let(:form) { create :form, :ready_for_live, :ready_for_routing }
      let(:page) { form.pages.first }

      context "with a single condition" do
        let(:goto_page) { form.pages.third }

        before do
          create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: goto_page.id, answer_value: "Option 1"

          page.reload
          form.reload.make_live!
        end

        it "returns the correct options" do
          expect(step_summary_card_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html", answer_value: "Option 1", goto_page_question_number: goto_page.position, goto_page_question_text: goto_page.question_text) },
            },
          )
        end
      end

      context "with multiple conditions" do
        let(:first_goto_page) { form.pages.third }
        let(:second_goto_page) { form.pages.fourth }

        before do
          create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: first_goto_page.id, answer_value: "Option 1"
          create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: second_goto_page.id, answer_value: "Option 2"

          page.reload
          form.reload.make_live!
        end

        it "returns the correct options" do
          first_condition_text = I18n.t("page_conditions.condition_compact_html", answer_value: "Option 1", goto_page_question_number: first_goto_page.position, goto_page_question_text: first_goto_page.question_text)
          second_condition_text = I18n.t("page_conditions.condition_compact_html", answer_value: "Option 2", goto_page_question_number: second_goto_page.position, goto_page_question_text: second_goto_page.question_text)

          expect(step_summary_card_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: "<ol class=\"govuk-list govuk-list--number\"><li>#{first_condition_text}</li><li>#{second_condition_text}</li></ol>" },
            },
          )
        end
      end

      context "with a condition that points to the end of the form" do
        before do
          create :condition, routing_page_id: page.id, check_page_id: page.id, skip_to_end: true, answer_value: "Option 1"

          page.reload
          form.reload.make_live!
        end

        it "returns the correct options" do
          expect(step_summary_card_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_end_of_form", answer_value: "Option 1") },
            },
          )
        end
      end

      context "with a secondary skip" do
        let(:page) { form.pages.second }

        before do
          create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, goto_page_id: pages.third.id, answer_value: "Option 1"
          create :condition, routing_page_id: page.id, check_page_id: pages.first.id, goto_page_id: pages.fourth.id

          page.reload
          form.reload.make_live!
        end

        it "returns the correct options" do
          expect(step_summary_card_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_secondary_skip", goto_page_question_number: pages.fourth.position, goto_page_question_text: pages.fourth.question_text) },
            },
          )
        end
      end

      context "with an exit page" do
        let!(:condition) { create :condition, :with_exit_page, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1" }

        before do
          page.reload
          form.reload.make_live!
        end

        it "returns the correct options" do
          expect(step_summary_card_service.all_options_for_answer_type).to include(
            {
              key: { text: I18n.t("page_conditions.route") },
              value: { text: I18n.t("page_conditions.condition_compact_html_exit_page", answer_value: condition.answer_value, exit_page_heading: condition.exit_page_heading) },
            },
          )
        end
      end
    end

    context "with guidance" do
      let(:page) { create :page, :with_guidance, form: }

      it "returns the correct page heading" do
        expect(step_summary_card_service.all_options_for_answer_type).to include(
          { key: { text: I18n.t("step_summary_card.page_heading") },
            value: { text: page.page_heading } },
        )
      end

      it "returns the correct guidance markdown" do
        expect(step_summary_card_service.all_options_for_answer_type).to include(
          { key: { text: I18n.t("step_summary_card.guidance_markdown") },
            value: { text: "<pre class=\"app-markdown-editor__markdown-example-block\">#{page.guidance_markdown}</pre>" } },
        )
      end

      context "when page doesn't have a page_heading or guidance_markdown method defined" do
        before do
          form_document_step.data.delete_field(:page_heading)
          form_document_step.data.delete_field(:guidance_markdown)
        end

        it "does not raise an error" do
          expect { step_summary_card_service.all_options_for_answer_type }.not_to raise_error
        end

        it "does not return a page heading key" do
          expect(step_summary_card_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("step_summary_card.page_heading") } },
          )
        end

        it "does not return a guidance markdown key" do
          expect(step_summary_card_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("step_summary_card.guidance_markdown") } },
          )
        end
      end
    end

    context "with answer type of file" do
      context "when file upload question does not have a page heading" do
        let(:page) { create :page, :with_file_upload_answer_type, form: }

        it "does not include the question text" do
          expect(step_summary_card_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("reports.form_or_questions_list_table.headings.question_text") },
              value: { text: page.question_text } },
          )
        end
      end

      context "when file upload question contains guidance text" do
        let(:page) { create :page, :with_guidance, :with_file_upload_answer_type, form: }

        it "returns question text" do
          expect(step_summary_card_service.all_options_for_answer_type).to include(
            { key: { text: I18n.t("reports.form_or_questions_list_table.headings.question_text") },
              value: { text: page.question_text } },
          )
        end

        it "does not return page heading" do
          expect(step_summary_card_service.all_options_for_answer_type).not_to include(
            { key: { text: I18n.t("step_summary_card.page_heading") } },
          )
        end
      end
    end
  end
end
