require "rails_helper"

RSpec.describe PageSettingsSummaryComponent::View, type: :component do
  include Rails.application.routes.url_helpers

  let(:draft_question) { build :draft_question }
  let(:errors) { instance_double(ActiveModel::Errors) }
  let(:selection_options_error_messages) { nil }
  let(:question_input) { Pages::QuestionInput.new(draft_question:, is_optional: "false", is_repeatable: "false") }
  let(:change_text_settings_path) { "https://example.com/change_text_settings" }
  let(:change_date_settings_path) { "https://example.com/change_date_settings" }
  let(:change_address_settings_path) { "https://example.com/change_address_settings" }
  let(:change_name_settings_path) { "https://example.com/change_name_settings" }

  let(:edit_answer_type_path) { type_of_answer_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_answer_type_path) { type_of_answer_new_path(form_id: draft_question.form_id) }

  let(:edit_address_setting_path) { address_settings_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_address_setting_path) { address_settings_new_path(form_id: draft_question.form_id) }
  let(:edit_date_setting_path) { date_settings_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_date_setting_path) { date_settings_new_path(form_id: draft_question.form_id) }
  let(:edit_name_setting_path) { name_settings_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_name_setting_path) { name_settings_new_path(form_id: draft_question.form_id) }
  let(:edit_selections_setting_path) { selections_settings_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_selections_setting_path) { selections_settings_new_path(form_id: draft_question.form_id) }
  let(:edit_text_setting_path) { text_settings_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_text_setting_path) { text_settings_new_path(form_id: draft_question.form_id) }
  let(:edit_long_lists_selection_type_path) { long_lists_selection_type_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_long_lists_selection_type_path) { long_lists_selection_type_new_path(form_id: draft_question.form_id) }
  let(:edit_long_lists_selection_options_path) { long_lists_selection_options_edit_path(form_id: draft_question.form_id, page_id: draft_question.page_id) }
  let(:new_long_lists_selection_options_path) { long_lists_selection_options_new_path(form_id: draft_question.form_id) }

  before do
    allow(errors).to receive(:has_key?).with(:selection_options).and_return(selection_options_error_messages.present?)
    allow(errors).to receive(:messages_for).with(:selection_options).and_return(selection_options_error_messages)
    render_inline(described_class.new(draft_question:, errors:))
  end

  context "when the page is not a selection page" do
    it "has a link to change the answer type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
    end

    it "does not have links to change the selection options" do
      expect(page).not_to have_link("Change #{I18n.t('page_settings_summary.selection.options')}", href: edit_selections_setting_path)
      expect(page).not_to have_link("Change #{I18n.t('page_settings_summary.selection.only_one_option')}", href: edit_selections_setting_path)
      expect(page).not_to have_link("Change #{I18n.t('page_settings_summary.selection.include_none_of_the_above')}", href: edit_selections_setting_path)
    end

    it "does not render the selection settings" do
      expect(page).not_to have_text "Selection from a list"
      expect(page).not_to have_text "Option 1, Option 2"
    end
  end

  context "when the draft question is a 'select from a list'" do
    context "when editing an existing question" do
      let(:only_one_option) { "false" }
      let(:is_optional) { false }
      let(:draft_question) do
        build :selection_draft_question,
              is_optional:,
              answer_settings: {
                only_one_option:,
                selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
              }
      end

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
      end

      context "when there are 10 or more selection options" do
        let(:only_one_option) { "false" }
        let(:draft_question) do
          build :selection_draft_question,
                answer_settings: {
                  only_one_option:,
                  selection_options: [{ name: "Option 1" },
                                      { name: "Option 2" },
                                      { name: "Option 3" },
                                      { name: "Option 4" },
                                      { name: "Option 5" },
                                      { name: "Option 6" },
                                      { name: "Option 7" },
                                      { name: "Option 8" },
                                      { name: "Option 9" },
                                      { name: "Option 10" }],
                }
        end

        it "has a details element containing the selection options" do
          details = page.find(".govuk-summary-list__row details")

          expect(details).to have_css("summary", text: I18n.t("page_settings_summary.selection.options_summary", number_of_options: "10"))
          expect(details).to have_css("li", text: "Option 1", visible: :all)
          expect(details).to have_css("li", text: "Option 2", visible: :all)
          expect(details).to have_css("li", text: "Option 3", visible: :all)
          expect(details).to have_css("li", text: "Option 4", visible: :all)
          expect(details).to have_css("li", text: "Option 5", visible: :all)
          expect(details).to have_css("li", text: "Option 6", visible: :all)
          expect(details).to have_css("li", text: "Option 7", visible: :all)
          expect(details).to have_css("li", text: "Option 8", visible: :all)
          expect(details).to have_css("li", text: "Option 9", visible: :all)
          expect(details).to have_css("li", text: "Option 10", visible: :all)
        end
      end

      context "when there is an error for the selection options" do
        let(:selection_options_error_messages) { ["A selection options error"] }

        it("highlights the summary list row with error formatting") do
          expect(page).to have_css(".govuk-summary-list__row.govuk-form-group--error", text: "Options")
        end

        it("displays an inline error message") do
          expect(page).to have_css("#pages-question-input-selection-options-field-error.govuk-error-message", text: selection_options_error_messages.first)
        end
      end

      context "when there is not an error for the selection options" do
        it("does not highlight the summary list row with error formatting") do
          expect(page).not_to have_css(".govuk-summary-list__row.govuk-form-group--error")
        end
      end

      context "when 'None of the above' is a setting" do
        let(:draft_question) { build :selection_draft_question, is_optional: true }

        it "renders the selection settings" do
          rows = page.find_all(".govuk-summary-list__row")

          expect(rows[0].find(".govuk-summary-list__key")).to have_text "Answer type"
          expect(rows[0].find(".govuk-summary-list__value")).to have_text "Selection from a list"
          expect(rows[1].find(".govuk-summary-list__key")).to have_text "Options"
          expect(rows[1].find(".govuk-summary-list__value")).to have_text "2 options:"
          expect(rows[1].find(".govuk-summary-list__value")).to have_css("li", text: "Option 1")
          expect(rows[1].find(".govuk-summary-list__value")).to have_css("li", text: "Option 2")
          expect(rows[2].find(".govuk-summary-list__key")).to have_text I18n.t("page_settings_summary.selection.how_many_selections")
          expect(rows[2].find(".govuk-summary-list__value")).to have_text I18n.t("helpers.label.pages_long_lists_selection_type_input.only_one_option_options.true")
          expect(rows[3].find(".govuk-summary-list__key")).to have_text "Include an option for ‘None of the above’"
          expect(rows[3].find(".govuk-summary-list__value")).to have_text "Yes"
        end
      end

      it "renders the selection settings" do
        rows = page.find_all(".govuk-summary-list__row")

        expect(rows[0].find(".govuk-summary-list__key")).to have_text "Answer type"
        expect(rows[0].find(".govuk-summary-list__value")).to have_text "Selection from a list"
        expect(rows[1].find(".govuk-summary-list__key")).to have_text "Options"
        expect(rows[1].find(".govuk-summary-list__value")).to have_text "2 options:"
        expect(rows[1].find(".govuk-summary-list__value")).to have_css("li", text: "Option 1")
        expect(rows[1].find(".govuk-summary-list__value")).to have_css("li", text: "Option 2")
        expect(rows[2].find(".govuk-summary-list__key")).to have_text I18n.t("page_settings_summary.selection.how_many_selections")
        expect(rows[2].find(".govuk-summary-list__value")).to have_text I18n.t("helpers.label.pages_long_lists_selection_type_input.only_one_option_options.false")
        expect(rows[3].find(".govuk-summary-list__key")).to have_text "Include an option for ‘None of the above’"
        expect(rows[3].find(".govuk-summary-list__value")).to have_text "No"
      end

      context "when only_one_option is true" do
        let(:only_one_option) { "true" }

        it "says people can select one or more options in the summary table" do
          rows = page.find_all(".govuk-summary-list__row")
          expect(rows[2].find(".govuk-summary-list__value")).to have_text I18n.t("helpers.label.pages_long_lists_selection_type_input.only_one_option_options.true")
        end
      end

      # This ensures there is backwards compatibility for existing questions as we previously set "only_one_option" to
      # "0" rather than "false"
      context "when only_one_option has value '0'" do
        let(:only_one_option) { "0" }

        it "says people can select only one option in the summary table" do
          rows = page.find_all(".govuk-summary-list__row")
          expect(rows[2].find(".govuk-summary-list__value")).to have_text I18n.t("helpers.label.pages_long_lists_selection_type_input.only_one_option_options.false")
        end
      end

      context "when is_optional is true" do
        let(:is_optional) { "true" }

        it "says an option for None of the above will be included" do
          rows = page.find_all(".govuk-summary-list__row")
          expect(rows[3].find(".govuk-summary-list__value")).to have_text "Yes"
        end
      end

      it "the change button for only one option links to the long lists type page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.only_one_option')}", href: edit_long_lists_selection_type_path)
      end

      it "the change button for the options links to the long lists options page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.options')}", href: edit_long_lists_selection_options_path)
      end

      it "the change button for include none of the above links to the longs lists options page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.include_none_of_the_above')}", href: edit_long_lists_selection_options_path)
      end
    end

    context "when creating a new question" do
      let(:draft_question) { build :selection_draft_question, page_id: nil }

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: new_answer_type_path)
      end

      it "the change button for only one option links to the long lists type page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.only_one_option')}", href: new_long_lists_selection_type_path)
      end

      it "the change button for the options links to the long lists options page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.options')}", href: new_long_lists_selection_options_path)
      end

      it "the change button for include none of the above links to the longs lists options page" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.selection.include_none_of_the_above')}", href: new_long_lists_selection_options_path)
      end
    end
  end

  context "when the page is a text page" do
    let(:draft_question) { build :text_draft_question, input_type: }
    let(:input_type) { "single_line" }

    it "has a link to change the answer type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
    end

    it "has links to change the text selections" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.text.length')}", href: edit_text_setting_path)
    end

    it "renders the input type" do
      expect(page).to have_text "Length"
      expect(page).to have_text I18n.t("helpers.label.page.text_settings_options.names.#{draft_question.answer_settings[:input_type]}")
    end

    context "when input_type is long text" do
      let(:input_type) { "long_text" }

      it "has links to change the text settings" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.text.length')}", href: edit_text_setting_path)
      end

      it "renders the input type" do
        expect(page).to have_text "Length"
        expect(page).to have_text I18n.t("helpers.label.page.text_settings_options.names.#{draft_question.answer_settings[:input_type]}")
      end
    end

    context "when draft_question is setup for new question" do
      let(:draft_question) { build :text_draft_question, page_id: nil }

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: new_answer_type_path)
      end

      it "has links to change the text selections" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.text.length')}", href: new_text_setting_path)
      end
    end
  end

  context "when the page is a date page" do
    let(:draft_question) { build :date_draft_question }

    it "has a link to change the answer type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
    end

    it "has a link to change the input type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.date.date_of_birth')}", href: edit_date_setting_path)
    end

    it "renders the input type" do
      expect(page).to have_text "Date of birth"
      expect(page).to have_text I18n.t("helpers.label.page.date_settings_options.input_types.#{draft_question.answer_settings[:input_type]}")
    end

    context "when the date has no answer settings" do
      let(:draft_question) { build :date_draft_question, answer_settings: nil }

      it "has no link to change the input type" do
        expect(page).not_to have_link("Change #{I18n.t('page_settings_summary.date.date_of_birth')}", href: edit_date_setting_path)
      end
    end

    context "when draft_question is setup for new question" do
      let(:draft_question) { build :date_draft_question, page_id: nil }

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: new_answer_type_path)
      end

      it "has links to change the date of birth setting" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.date.date_of_birth')}", href: new_date_setting_path)
      end
    end
  end

  context "when the page is an address page" do
    let(:draft_question) { build :address_draft_question, uk_address:, international_address: }
    let(:uk_address) { "true" }
    let(:international_address) { "true" }

    it "has a link to change the answer type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
    end

    it "has links to change the answer settings" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.address.address_type')}", href: edit_address_setting_path)
    end

    it "renders the input type" do
      expect(page).to have_text "Address type"
      expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses")
    end

    context "when the input type is uk addresses only" do
      let(:uk_address) { "true" }
      let(:international_address) { "false" }

      it "renders the input type as uk addresses" do
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.uk_addresses")
      end
    end

    context "when the input type is international addresses only" do
      let(:uk_address) { "false" }
      let(:international_address) { "true" }

      it "renders the input type as international addresses" do
        expect(page).to have_text I18n.t("helpers.label.page.address_settings_options.names.international_addresses")
      end
    end

    context "when draft_question is setup for new question" do
      let(:draft_question) { build :address_draft_question, page_id: nil }

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: new_answer_type_path)
      end

      it "has a link to change the address type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.address.address_type')}", href: new_address_setting_path)
      end
    end
  end

  context "when the page is a name page" do
    let(:draft_question) { build :name_draft_question, input_type:, title_needed: }
    let(:input_type) { "full_name" }
    let(:title_needed) { "true" }

    it "has a link to change the answer type" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: edit_answer_type_path)
    end

    it "has links to change the answer settings" do
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.name.name_fields')}", href: edit_name_setting_path)
      expect(page).to have_link("Change #{I18n.t('page_settings_summary.name.title_needed')}", href: edit_name_setting_path)
    end

    it "renders the input type" do
      expect(page).to have_text "Name fields"
      expect(page).to have_text I18n.t("helpers.label.page.name_settings_options.names.full_name")
    end

    it "renders the title needed" do
      expect(page).to have_text "Title needed"
      expect(page).to have_text I18n.t("helpers.label.page.name_settings_options.names.true")
    end

    context "when draft_question is setup for new question" do
      let(:draft_question) { build :name_draft_question, page_id: nil }

      it "has a link to change the answer type" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.answer_type')}", href: new_answer_type_path)
      end

      it "has a link to change the name fields" do
        expect(page).to have_link("Change #{I18n.t('page_settings_summary.name.name_fields')}", href: new_name_setting_path)
      end
    end
  end
end
