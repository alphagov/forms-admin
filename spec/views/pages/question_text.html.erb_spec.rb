require "rails_helper"

describe "pages/question_text.html.erb" do
  let(:form) { build :form, id: 1, pages: [] }
  let(:question_text_form) { build :question_text_form }
  let(:question_text_path) { "/forms/1/pages/new/question_text" }
  let(:form_pages_path) { "/forms/1/pages/new/guidance" }
  let(:back_link_url) { "/forms/1/pages/new/type-of-answer" }

  before do
    without_partial_double_verification do
      allow(view).to receive(:form_pages_path).and_return(form_pages_path)
      allow(view).to receive(:current_form).and_return(form)
    end

    # Assign instance variables so they can be accessed from views
    assign(:question_text_form, question_text_form)
    assign(:question_text_path, question_text_path)
    assign(:back_link_url, back_link_url)

    render template: "pages/question_text", locals: { current_form: form }
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(I18n.t("page_titles.question_text"))
  end

  it "has a back link to the type of answer page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: back_link_url)
  end

  it "has the correct heading" do
    expect(rendered).to have_selector("h1", text: I18n.t("helpers.label.pages_question_text_form.question_text"))
  end

  it "includes a form field for entering your question text" do
    expect(rendered).to have_field(I18n.t("helpers.label.pages_question_text_form.question_text"))
  end
end
