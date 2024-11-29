require "rails_helper"

RSpec.describe "pages/new" do
  let(:current_form) { build :form, :with_active_resource, id: 1, pages: [] }
  let(:draft_question) { build :draft_question }
  let(:question_input) { build :question_input, draft_question:, answer_type: draft_question.answer_type, question_text: draft_question.question_text, answer_settings: draft_question.answer_settings, is_optional: draft_question.is_optional, is_repeatable: draft_question.is_repeatable }

  before do
    assign(:question_input, question_input)

    render locals: { current_form:, draft_question: }
  end

  it "renders" do
    expect(rendered).not_to be_blank
  end

  it "has a back link to the add and edit questions page" do
    expect(view.content_for(:back_link)).to have_link "Back", href: form_pages_path(form_id: 1)
  end

  it "has a page title" do
    expect(view.content_for(:title)).to eq "Edit question"
  end

  it "has a page heading" do
    expect(rendered).to have_css "h1", normalize_ws: true, text: "Question 1 - Edit question"
  end

  describe "page heading" do
    it "includes the question number as a caption" do
      expect(rendered).to have_css "h1.govuk-heading-l .govuk-caption-l", text: "Question 1"
    end

    describe "question number" do
      context "when the current form already has some pages" do
        let(:current_form) { build :form, :with_active_resource, id: 1, pages: build_list(:page, 3) }

        it "is one greater than the number of existing pages" do
          expect(rendered).to have_css "h1.govuk-heading-l .govuk-caption-l", text: "Question 4"
        end
      end
    end
  end

  it "renders a form to edit the new page" do
    expect(rendered).to have_rendered("pages/_form")
  end

  describe "form" do
    it "saves the new question" do
      expect(rendered).to have_element "form", action: create_question_path(form_id: 1)
    end

    it "has a link to add guidance" do
      expect(rendered).to have_link href: guidance_new_path(form_id: 1)
    end

    it "does not have a button to delete the question" do
      expect(rendered).not_to have_button "Delete question"
    end

    it "does not have a link to edit the next question" do
      expect(rendered).not_to have_link "Edit next question"
    end

    it "does not have a link to add another question" do
      expect(rendered).not_to have_link "Add a question"
    end
  end
end
