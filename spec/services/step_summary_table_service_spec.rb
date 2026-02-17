require "rails_helper"

describe StepSummaryTableService do
  subject(:step_summary_table_service) do
    described_class.new(step: form_document_step, steps: form_document_steps, welsh_steps: welsh_form_document_steps)
  end

  let(:form) { create :form, :with_welsh_translation, :live, id: 1, pages: [page] }
  let(:page) { create(:page) }

  let(:form_document_content) { FormDocument::Content.from_form_document(form.live_form_document) }
  let(:welsh_form_document_content) { FormDocument::Content.from_form_document(form.live_welsh_form_document) }
  let(:form_document_steps) { form_document_content.steps }
  let(:welsh_form_document_steps) { welsh_form_document.steps }
  let(:form_document_step) { FormDocument::Step.new(page.as_form_document_step(nil)) }
  let(:welsh_form_document) { FormDocument::Content.from_form_document(form.live_welsh_form_document) }

  def create_form(attributes = {})
    default_attributes = {
      id: 1,
      name: "Apply for a juggling licence",
      name_cy: "Apply for a juggling licence (Welsh)",
      what_happens_next_markdown: "English what happens next",
      what_happens_next_markdown_cy: "Welsh what happens next",
      declaration_text: "English declaration",
      declaration_text_cy: "Welsh declaration",
      support_email: "english-support@example.gov.uk",
      support_email_cy: "welsh-support@example.gov.uk",
      support_phone: "01234 987654",
      support_phone_cy: "01234 567891",
      support_url_cy: "https://www.gov.uk/welsh-support",
      support_url: "https://www.gov.uk/english-support",
      support_url_text_cy: "Welsh Support",
      support_url_text: "English Support",
      privacy_policy_url: "https://www.gov.uk/english-privacy",
      privacy_policy_url_cy: "https://www.gov.uk/welsh-privacy",
      payment_url: "https://www.gov.uk/english-payment",
      payment_url_cy: "https://www.gov.uk/payments/your-welsh-payment-link",
      welsh_completed: true,
      question_section_completed: true,
      declaration_section_completed: true,
      share_preview_completed: true,
      pages: [],
    }
    create(:form, :live, default_attributes.merge(attributes))
  end

  def create_page(attributes = {})
    default_attributes = {
      question_text: "Are you renewing a licence?",
      hint_text: "Choose 'Yes' if you already have a valid licence.",
      page_heading: "Licencing",
      guidance_markdown: "This part of the form concerns licencing.",
      question_text_cy: "Ydych chi'n adnewyddu trwydded?",
      hint_text_cy: "Dewiswch 'Ydw' os oes gennych drwydded ddilys eisoes.",
      page_heading_cy: "Trwyddedu",
      guidance_markdown_cy: "Mae'r rhan hon o'r ffurflen yn ymwneud â thrwyddedu.",
      form:,
    }
    create(:page, default_attributes.merge(attributes))
  end

  describe "#values_with_welsh_content" do
    context "when the page includes guidance markdown" do
      let(:page) do
        create(:page,
               question_text: "Are you renewing a licence?",
               question_text_cy: "Ydych chi'n adnewyddu trwydded?",
               page_heading: "Licencing",
               guidance_markdown: "This part of the form concerns licencing.",
               page_heading_cy: "Trwyddedu",
               guidance_markdown_cy: "Mae'r rhan hon o'r ffurflen yn ymwneud â thrwyddedu.")
      end

      it "includes a row for the page heading" do
        expect(step_summary_table_service.values_with_welsh_content).to include [I18n.t("step_summary_card.page_heading"), page.page_heading, page.page_heading_cy]
      end

      it "includes a formatted row for the guidance markdown" do
        expect(step_summary_table_service.values_with_welsh_content).to include [
          I18n.t("step_summary_card.guidance_markdown"),
          "<pre class=\"app-markdown-editor__markdown-example-block\">".html_safe + page.guidance_markdown + "</pre>".html_safe,
          "<pre class=\"app-markdown-editor__markdown-example-block\">".html_safe + page.guidance_markdown_cy + "</pre>".html_safe,
        ]
      end

      it "includes a row for the question text" do
        expect(step_summary_table_service.values_with_welsh_content).to include ["Question text", page.question_text, page.question_text_cy]
      end
    end

    context "when the page includes hint_text" do
      let(:page) do
        create(:page,
               question_text: "Are you renewing a licence?",
               question_text_cy: "Ydych chi'n adnewyddu trwydded?",
               hint_text: "Choose 'Yes' if you already have a valid licence.",
               hint_text_cy: "Dewiswch 'Ydw' os oes gennych drwydded ddilys eisoes.")
      end

      it "includes a row for the hint text" do
        expect(step_summary_table_service.values_with_welsh_content).to include [I18n.t("step_summary_card.hint_text"),
                                                                                 page.hint_text,
                                                                                 page.hint_text_cy]
      end
    end

    context "when the page is a selection question" do
      let(:page) do
        create(:page,
               question_text: "Are you renewing a licence?",
               question_text_cy: "Ydych chi'n adnewyddu trwydded?",
               answer_type: "selection",
               answer_settings: {
                 "only_one_option" => "true",
                 "selection_options" => [{ name: "Yes" }, { name: "No" }],
               }.to_json,
               answer_settings_cy: {
                 "only_one_option" => "true",
                 "selection_options" => [{ name: "Ydy" }, { name: "Nac ydy" }],
               }.to_json)
      end

      it "includes a row for the selection options" do
        selection_list = "<p class=\"govuk-body-s\">#{I18n.t('page_settings_summary.selection.options_count', number_of_options: 2)}</p><ul class=\"govuk-list govuk-list--bullet\"><li>Yes</li><li>No</li></ul>"
        selection_list_cy = "<p class=\"govuk-body-s\">#{I18n.t('page_settings_summary.selection.options_count', number_of_options: 2)}</p><ul class=\"govuk-list govuk-list--bullet\"><li>Ydy</li><li>Nac ydy</li></ul>"
        expect(step_summary_table_service.values_with_welsh_content).to include [I18n.t("step_summary_card.options_title"), selection_list, selection_list_cy]
      end

      context "when there are more than 10 options" do
        let(:page) do
          create(:page,
                 question_text: "Are you renewing a licence?",
                 question_text_cy: "Ydych chi'n adnewyddu trwydded?",
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [
                     { name: "One" },
                     { name: "Two" },
                     { name: "Three" },
                     { name: "Four" },
                     { name: "Five" },
                     { name: "Six" },
                     { name: "Seven" },
                     { name: "Eight" },
                     { name: "Nine" },
                     { name: "Ten" },
                     { name: "Eleven" },
                   ],
                 }.to_json,
                 answer_settings_cy: {
                   "only_one_option" => "true",
                   "selection_options" => [
                     { name: "Un" },
                     { name: "Dau" },
                     { name: "Tri" },
                     { name: "Pedwar" },
                     { name: "Pum" },
                     { name: "Chwe" },
                     { name: "Saith" },
                     { name: "Wyth" },
                     { name: "Naw" },
                     { name: "Deg" },
                     { name: "Un ar ddeg" },
                   ],
                 }.to_json)
        end

        it "includes a row with the selection options in a details component" do
          selection_list = "<details class=\"govuk-details\"><summary class=\"govuk-details__summary\"><span class=\"govuk-details__summary-text\">Show 11 options</span></summary><div class=\"govuk-details__text\"><ul class=\"govuk-list govuk-list--bullet\"><li>One</li><li>Two</li><li>Three</li><li>Four</li><li>Five</li><li>Six</li><li>Seven</li><li>Eight</li><li>Nine</li><li>Ten</li><li>Eleven</li></ul></div></details>"
          selection_list_cy = "<details class=\"govuk-details\"><summary class=\"govuk-details__summary\"><span class=\"govuk-details__summary-text\">Show 11 options</span></summary><div class=\"govuk-details__text\"><ul class=\"govuk-list govuk-list--bullet\"><li>Un</li><li>Dau</li><li>Tri</li><li>Pedwar</li><li>Pum</li><li>Chwe</li><li>Saith</li><li>Wyth</li><li>Naw</li><li>Deg</li><li>Un ar ddeg</li></ul></div></details>"
          expect(step_summary_table_service.values_with_welsh_content).to include [I18n.t("step_summary_card.options_title"), selection_list, selection_list_cy]
        end
      end

      context "when there is custom 'None of the above' text" do
        let(:page) do
          create(:page,
                 is_optional: true,
                 question_text: "Are you renewing a licence?",
                 question_text_cy: "Ydych chi'n adnewyddu trwydded?",
                 answer_type: "selection",
                 answer_settings: {
                   "only_one_option" => "true",
                   "selection_options" => [
                     { name: "Yes" },
                     { name: "No" },
                   ],
                   none_of_the_above_question: { question_text: "Enter something" },
                 }.to_json,
                 answer_settings_cy: {
                   "only_one_option" => "true",
                   "selection_options" => [
                     { name: "Ydy" },
                     { name: "Nac ydy" },
                   ],
                   none_of_the_above_question: { question_text: "Rhowch rywbeth i mewn" },
                 }.to_json)
        end

        it "includes a row with the none of the above text" do
          expect(step_summary_table_service.values_with_welsh_content).to include [I18n.t("step_summary_card.none_of_the_above_question_title"), page.answer_settings[:none_of_the_above_question][:question_text], page.answer_settings_cy[:none_of_the_above_question][:question_text]]
        end
      end
    end
  end

  describe "#untranslated_content" do
    let(:page) do
      create(:page,
             question_text: "Are you renewing a licence?",
             question_text_cy: "Ydych chi'n adnewyddu trwydded?",
             answer_type:,
             answer_settings:,
             answer_settings_cy: answer_settings)
    end

    context "when the page is a text question" do
      let(:answer_type) { "text" }

      context "when the page is configured as a single line of text" do
        let(:answer_settings) { { input_type: "single_line" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.text_settings_options.names.single_line"),
          })
        end
      end

      context "when the page is configured as long text" do
        let(:answer_settings) { { input_type: "long_text" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.text_settings_options.names.long_text"),
          })
        end
      end
    end

    context "when the page is a date question" do
      let(:answer_type) { "date" }

      context "when the page is configured as a generic date" do
        let(:answer_settings) { { input_type: "other_date" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("step_summary_card.date_type.other_date"),
          })
        end
      end

      context "when the page is configured as a date of birth" do
        let(:answer_settings) { { input_type: "date_of_birth" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("step_summary_card.date_type.date_of_birth"),
          })
        end
      end
    end

    context "when the page is a address question" do
      let(:answer_type) { "address" }

      context "when the page is configured as a UK address" do
        let(:answer_settings) do
          {
            input_type: {
              uk_address: "true",
              international_address: "false",
            },
          }
        end

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses"),
          })
        end
      end

      context "when the page is configured as an international address" do
        let(:answer_settings) do
          {
            input_type: {
              uk_address: "false",
              international_address: "true",
            },
          }
        end

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.address_settings_options.names.international_addresses"),
          })
        end
      end

      context "when the page is configured as a UK or international address" do
        let(:answer_settings) do
          {
            input_type: {
              uk_address: "true",
              international_address: "true",
            },
          }
        end

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses"),
          })
        end
      end
    end

    context "when the page is a name question" do
      let(:answer_type) { "name" }

      context "when the page is configured as a full name" do
        let(:answer_settings) { { input_type: "full_name", title_needed: "false" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: "<ul class=\"govuk-list\"><li>#{I18n.t('helpers.label.page.answer_type_options.names.name')}</li><li>#{I18n.t('helpers.label.page.name_settings_options.names.full_name')}</li><li>#{I18n.t('step_summary_card.name_type.title_not_selected')}</li></ul>",
          })
        end
      end

      context "when the page is configured as a first and last name" do
        let(:answer_settings) { { input_type: "first_and_last_name", title_needed: "false" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: "<ul class=\"govuk-list\"><li>#{I18n.t('helpers.label.page.answer_type_options.names.name')}</li><li>#{I18n.t('helpers.label.page.name_settings_options.names.first_and_last_name')}</li><li>#{I18n.t('step_summary_card.name_type.title_not_selected')}</li></ul>",
          })
        end
      end

      context "when the page is configured as a first, last, and middle names" do
        let(:answer_settings) { { input_type: "first_middle_and_last_name", title_needed: "false" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: "<ul class=\"govuk-list\"><li>#{I18n.t('helpers.label.page.answer_type_options.names.name')}</li><li>#{I18n.t('helpers.label.page.name_settings_options.names.first_middle_and_last_name')}</li><li>#{I18n.t('step_summary_card.name_type.title_not_selected')}</li></ul>",
          })
        end
      end

      context "when the page is configured to ask for a title" do
        let(:answer_settings) { { input_type: "full_name", title_needed: "true" } }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: "<ul class=\"govuk-list\"><li>#{I18n.t('helpers.label.page.answer_type_options.names.name')}</li><li>#{I18n.t('helpers.label.page.name_settings_options.names.full_name')}</li><li>#{I18n.t('step_summary_card.name_type.title_selected')}</li></ul>",
          })
        end
      end
    end

    Page::ANSWER_TYPES_WITHOUT_SETTINGS.each do |answer_type_without_settings|
      context "when the page has answer type #{answer_type_without_settings}" do
        let(:answer_type) { answer_type_without_settings }
        let(:answer_settings) { nil }

        it "returns data for the Answer Type details component" do
          expect(step_summary_table_service.untranslated_content).to eq({
            summary: I18n.t("step_summary_card.answer_type"),
            text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type_without_settings}"),
          })
        end
      end
    end
  end
end
