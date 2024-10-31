require "rails_helper"

describe "pages/long_lists_selection/bulk_options.html.erb", type: :view do
  let(:form) { build :form, id: 1, pages: [page] }
  let(:bulk_options_input) { build :bulk_options_input, draft_question: page }
  let(:page) { OpenStruct.new(answer_type: "selection", answer_settings:) }
  let(:answer_settings) { OpenStruct.new(only_one_option:, selection_options:) }
  let(:only_one_option) { "true" }
  let(:selection_options) { [] }
  let(:page_number) { 1 }
  let(:back_link_url) { "/a-back-link-url" }

  before do
    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(page_number)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_path: "/type-of-answer", current_form: form)
    end

    # # setup instance variables
    bulk_options_input.assign_form_values
    @bulk_options_input = bulk_options_input
    @bulk_options_path = bulk_options_create_path(form.id)
    @back_link_url = back_link_url
  end

  context "when there are no errors" do
    before do
      render(template: "pages/long_lists_selection/bulk_options")
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

    it "has explanatory guidance" do
      expect(rendered).to have_content(I18n.t("bulk_options.select_one_option"))
      expect(rendered).to have_content(I18n.t("bulk_options.longer_than_30_options"))
    end

    it "has a textbox for entering options" do
      expect(rendered).to have_field(I18n.t("bulk_options.label"), type: "textarea")
    end

    it "contains a radio question for choosing whether to make the form live" do
      expect(rendered).to have_css("fieldset", text: I18n.t("helpers.legend.pages_long_lists_selection_bulk_options_input.include_none_of_the_above"))
      expect(rendered).to have_field("Yes", type: "radio")
      expect(rendered).to have_field("No", type: "radio")
    end
  end

  context "when there are errors" do
    before do
      bulk_options_input.errors.add(:include_none_of_the_above, "Select ‘Yes’ or ‘No’")
      render(template: "pages/long_lists_selection/bulk_options")
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix(t("page_titles.bulk_options"), true))
    end
  end
end
