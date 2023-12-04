require "rails_helper"

describe "pages/index.html.erb" do
  let(:form) { build :form, id: 1, pages: }
  let(:pages) { [] }

  before do
    # mock the path helper
    without_partial_double_verification do
      allow(view).to receive(:form_path).and_return("/forms/1")
      allow(view).to receive(:type_of_answer_new_path).and_return("/forms/1/pages/new/type-of-answer")
      allow(view).to receive(:edit_question_path).and_return("/forms/1/pages/2/edit/question")
      allow(view).to receive(:form_pages_path).and_return("/forms/1/pages")
      allow(view).to receive(:routing_page_path).and_return("/forms/1/new-condition")
      allow(view).to receive(:current_form).and_return(form)
    end
    assign(:pages, pages)
    render template: "pages/index"
  end

  describe "when there are no pages to display" do
    it "allows the user to add a page" do
      expect(rendered).to have_link(I18n.t("pages.index.add_question"), href: start_new_question_path(form.id))
    end

    it "does not contain a link to add page routing" do
      expect(rendered).not_to have_link("Add a question route", href: routing_page_path(form.id))
    end

    it "does not contain a list of pages" do
      expect(rendered).not_to have_text I18n.t("forms.form_overview.your_questions")
      expect(rendered).not_to have_css ".govuk-summary-list"
    end
  end

  describe "when there are one or more page to display" do
    let(:pages) { [(build :page, id: 1, position: 1, form_id: 1), (build :page, id: 2, position: 2, form_id: 1), (build :page, id: 3, position: 3, form_id: 1)] }

    it "allows the user to add a page" do
      expect(rendered).to have_link(I18n.t("pages.index.add_question"), href: start_new_question_path(form.id))
    end

    it "does contain a summary list entry each page" do
      expect(rendered).to have_text I18n.t("forms.form_overview.your_questions")
      expect(rendered).to have_css ".govuk-summary-list__row", count: 3
    end
  end
end
