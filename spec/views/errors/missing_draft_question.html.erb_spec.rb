require "rails_helper"

describe "errors/missing_draft_question.html.erb" do
  let(:form) { create :form }

  before do
    assign(:current_form, form)

    render
  end

  it "has a page title" do
    expect(view.content_for(:title)).to include I18n.t("page_titles.missing_draft_question")
  end

  it "has a heading" do
    expect(rendered).to have_css "h1", text: I18n.t("page_titles.missing_draft_question")
  end

  it "informs the user about the expired data" do
    expect(rendered).to have_css "p", text: I18n.t("errors.missing_draft_question.expired_data")
  end

  it "suggests possible causes of the error" do
    expect(rendered).to have_css "p", text: I18n.t("errors.missing_draft_question.possible_causes")
  end

  it "has information about next steps" do
    expect(rendered).to include I18n.t("errors.missing_draft_question.next_steps_html", add_question_link: start_new_question_path(form.id), questions_link: form_pages_path(form.id))
  end
end
