require "rails_helper"

describe "pages/selection/bulk_options.html.erb", type: :view do
  let(:form) { create :form }
  let(:page) { create :page, :with_selection_settings, answer_settings: }
  let(:bulk_options_input) { build :bulk_options_input, draft_question: page, include_none_of_the_above: }
  let(:include_none_of_the_above) { "yes" }
  let(:answer_settings) { DataStruct.new(only_one_option:, selection_options:) }
  let(:only_one_option) { "true" }
  let(:selection_options) { [] }
  let(:page_number) { 1 }
  let(:back_link_url) { "/a-back-link-url" }
  let(:describe_none_of_the_above_enabled) { true }

  before do
    form.reload

    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(page_number)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_path: "/type-of-answer", current_form: form)
    end

    allow(FeatureService).to receive(:enabled?).with(:describe_none_of_the_above_enabled).and_return(describe_none_of_the_above_enabled)

    # # setup instance variables
    @bulk_options_input = bulk_options_input
    @bulk_options_path = selection_bulk_options_create_path(form.id)
    @back_link_url = back_link_url
  end

  context "when there are no errors" do
    before do
      render(template: "pages/selection/bulk_options")
    end

    it "does not display the error summary" do
      expect(rendered).not_to have_selector(".govuk-error-summary")
    end

    it "has a back link" do
      expect(view.content_for(:back_link)).to have_link("Back", href: back_link_url)
    end

    it "has the question number in a caption" do
      expect(rendered).to have_css(".govuk-caption-l", text: "Question #{page_number}")
    end

    it "has the correct heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.bulk_options"))
    end

    context "when only_one_option is set to 'true' for the draft question" do
      let(:only_one_option) { "true" }

      it "contains guidance about users selecting one option" do
        expect(rendered).to have_content(I18n.t("bulk_options.select_one_option"))
      end

      it "contains guidance about what happens if there are more than 30 options" do
        expect(rendered).to have_content(I18n.t("bulk_options.longer_than_30_options"))
      end

      it "does not contain guidance about users selecting more than one option" do
        expect(rendered).not_to have_content(I18n.t("bulk_options.select_more_than_one_option"))
      end

      it "does not contain guidance about adding up to 30 options" do
        expect(rendered).not_to have_content(I18n.t("bulk_options.up_to_30_options"))
      end
    end

    context "when only_one_option is set to 'false' for the draft question" do
      let(:only_one_option) { "false" }

      it "contains guidance about users selecting more than one option" do
        expect(rendered).to have_content(I18n.t("bulk_options.select_more_than_one_option"))
      end

      it "contains guidance about adding up to 30 options" do
        expect(rendered).to have_content(I18n.t("bulk_options.up_to_30_options"))
      end

      it "does not contain guidance about users selecting one option" do
        expect(rendered).not_to have_content(I18n.t("bulk_options.select_one_option"))
      end

      it "does not contain guidance about what happens if there are more than 30 options" do
        expect(rendered).not_to have_content(I18n.t("bulk_options.longer_than_30_options"))
      end
    end

    it "has a textbox for entering options" do
      expect(rendered).to have_field(I18n.t("bulk_options.label"), type: "textarea")
    end

    describe "include none of the above radios" do
      context "when the describe_none_of_the_above_enabled feature is enabled" do
        it "contains a radio question for choosing whether to make the form live" do
          expect(rendered).to have_css("fieldset", text: I18n.t("helpers.legend.pages_selection_bulk_options_input.include_none_of_the_above"))
          expect(rendered).to have_field(I18n.t("helpers.label.pages_selection_bulk_options_input.include_none_of_the_above_options.yes"), type: "radio")
          expect(rendered).to have_field(I18n.t("helpers.label.pages_selection_bulk_options_input.include_none_of_the_above_options.yes_with_question"), type: "radio")
          expect(rendered).to have_field(I18n.t("helpers.label.pages_selection_bulk_options_input.include_none_of_the_above_options.no"), type: "radio")
        end

        context "when input object has value of yes'" do
          let(:include_none_of_the_above) { "yes" }

          it "has 'Yes' radio selected" do
            expect(rendered).to have_checked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes_with_question")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "no")
          end
        end

        context "when input object has value of yes_with_question" do
          let(:include_none_of_the_above) { "yes_with_question" }

          it "has 'No' radio selected" do
            expect(rendered).to have_checked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes_with_question")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "no")
          end
        end

        context "when input object has value of no" do
          let(:include_none_of_the_above) { "no" }

          it "has 'No' radio selected" do
            expect(rendered).to have_checked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "no")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes_with_question")
          end
        end

        context "when input object has no value set" do
          let(:include_none_of_the_above) { nil }

          it "does not have a radio option selected" do
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "no")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes")
            expect(rendered).to have_unchecked_field("pages_selection_bulk_options_input[include_none_of_the_above]", with: "yes_with_question")
          end
        end
      end

      context "when the describe_none_of_the_above_enabled feature is disabled" do
        let(:describe_none_of_the_above_enabled) { false }

        it "does not render the yes_with_question radio option" do
          expect(rendered).not_to have_field(I18n.t("helpers.label.pages_selection_bulk_options_input.include_none_of_the_above_options.yes_with_question"))
        end
      end
    end
  end

  context "when there are errors" do
    before do
      bulk_options_input.errors.add(:include_none_of_the_above, "Select ‘Yes’ or ‘No’")
      render(template: "pages/selection/bulk_options")
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.bulk_options"), true))
    end
  end
end
